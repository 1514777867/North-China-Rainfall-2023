from mpi4py import MPI
import netCDF4
import numpy as np
import fiona
import os
import shapely
from shapely.geometry import shape
from shapely.ops import unary_union
from shapely.wkb import dumps as wkb_dumps
from shapely.wkb import loads as wkb_loads

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

nc_file = "trmask_d01"
shp_directory = "./shapefiles"

# shapefile_names = ["South_China_Land.shp", "Hainan.shp", "Taiwan.shp"]
shapefile_names = ["Bay_of_Bengal.shp"]
# shapefile_names = ["Western_Pacific.shp"]
# shapefile_names = ["South_China_Sea.shp"]
# shapefile_names = ["India.shp"]

def read_coordinate_2d(variable):
    data = np.asarray(variable[:])
    if data.ndim == 3:
        data = data[0, :, :]
    elif data.ndim != 2:
        raise ValueError(f"{variable.name} 维度不正确，当前形状为 {data.shape}")
    return np.ascontiguousarray(data, dtype=np.float64)

if rank == 0:
    print("=" * 70)
    print(f"MPI 进程数: {size}")
    print(f"读取 NetCDF: {nc_file}")
    ds = netCDF4.Dataset(nc_file, "r+")
    lat = read_coordinate_2d(ds.variables["XLAT"])
    lon = read_coordinate_2d(ds.variables["XLONG"])
    trmask = ds.variables["TRMASK3D"]
    if trmask.ndim != 4:
        raise ValueError(f"TRMASK3D 应为四维变量，当前形状为 {trmask.shape}")
    ntime, nz, ny, nx = trmask.shape
    if lat.shape != (ny, nx):
        raise ValueError(f"XLAT 形状 {lat.shape} 与 TRMASK3D 网格 {(ny, nx)} 不一致")
    if lon.shape != (ny, nx):
        raise ValueError(f"XLONG 形状 {lon.shape} 与 TRMASK3D 网格 {(ny, nx)} 不一致")
    print(f"网格大小: nx={nx}, ny={ny}, nz={nz}, ntime={ntime}")
    print(f"经度范围: {np.nanmin(lon):.3f} ～ {np.nanmax(lon):.3f}")
    print(f"纬度范围: {np.nanmin(lat):.3f} ～ {np.nanmax(lat):.3f}")
else:
    ds = None
    trmask = None
    lat = None
    lon = None
    ntime = nz = ny = nx = None

ntime = comm.bcast(ntime, root=0)
nz = comm.bcast(nz, root=0)
ny = comm.bcast(ny, root=0)
nx = comm.bcast(nx, root=0)

if rank != 0:
    lat = np.empty((ny, nx), dtype=np.float64)
    lon = np.empty((ny, nx), dtype=np.float64)

comm.Bcast(lat, root=0)
comm.Bcast(lon, root=0)

base_rows, remainder = divmod(ny, size)
local_nrows = base_rows + (1 if rank < remainder else 0)
start = rank * base_rows + min(rank, remainder)
end = start + local_nrows
print(f"rank {rank:03d}: 处理行 {start} ～ {end - 1}，共 {local_nrows} 行", flush=True)

if rank == 0:
    all_geometries = []
    shapefile_crs = []
    print("=" * 70)
    print("读取并合并 shapefile")
    for shp_name in shapefile_names:
        shp_path = os.path.join(shp_directory, shp_name)
        if not os.path.exists(shp_path):
            print(f"文件不存在，跳过: {shp_path}")
            continue
        try:
            with fiona.open(shp_path, "r") as shp:
                if shp.crs:
                    shapefile_crs.append((shp_name, str(shp.crs)))
                count_before = len(all_geometries)
                for feature in shp:
                    geometry_data = feature.get("geometry")
                    if geometry_data is None:
                        continue
                    geom = shape(geometry_data)
                    if not geom.is_empty:
                        all_geometries.append(geom)
                number_read = len(all_geometries) - count_before
                print(f"{shp_name}: 读取 {number_read} 个有效几何对象")
        except Exception as exc:
            print(f"读取 {shp_name} 失败: {exc}")

    if not all_geometries:
        print("没有成功读取任何有效多边形")
        ds.close()
        comm.Abort(1)

    print(f"开始合并 {len(all_geometries)} 个几何对象……")
    region = unary_union(all_geometries)
    if region.is_empty:
        print("合并后的区域为空")
        ds.close()
        comm.Abort(1)

    print(f"合并完成，几何类型: {region.geom_type}")
    print(f"区域范围: {region.bounds[0]:.3f}/{region.bounds[2]:.3f}/{region.bounds[1]:.3f}/{region.bounds[3]:.3f}")
    if shapefile_crs:
        print(f"Shapefile 坐标系: {shapefile_crs[0][0]}: {shapefile_crs[0][1]}")
    region_wkb = wkb_dumps(region)
else:
    region_wkb = None

region_wkb = comm.bcast(region_wkb, root=0)
region = wkb_loads(region_wkb)

lon_local = lon[start:end, :]
lat_local = lat[start:end, :]
mask_bool = np.zeros((local_nrows, nx), dtype=bool)

min_lon, min_lat, max_lon, max_lat = region.bounds
candidate = (
    np.isfinite(lon_local)
    & np.isfinite(lat_local)
    & (lon_local >= min_lon)
    & (lon_local <= max_lon)
    & (lat_local >= min_lat)
    & (lat_local <= max_lat)
)

comm.Barrier()
calculation_start = MPI.Wtime()

if np.any(candidate):
    candidate_lon = lon_local[candidate]
    candidate_lat = lat_local[candidate]
    if hasattr(shapely, "contains_xy"):
        if hasattr(shapely, "prepare"):
            shapely.prepare(region)
        mask_bool[candidate] = shapely.contains_xy(region, candidate_lon, candidate_lat)
    else:
        try:
            from shapely.vectorized import contains as vectorized_contains
            mask_bool[candidate] = vectorized_contains(region, candidate_lon, candidate_lat)
        except ImportError:
            print(f"rank {rank}: 当前 Shapely 不支持向量化 contains，建议升级到 Shapely 2.x", flush=True)
            comm.Abort(1)

mask_local = mask_bool.astype(np.float32)
local_calculation_time = MPI.Wtime() - calculation_start
max_calculation_time = comm.reduce(local_calculation_time, op=MPI.MAX, root=0)

sendbuf = np.ascontiguousarray(mask_local.ravel())

if rank == 0:
    row_counts = np.array([base_rows + (1 if r < remainder else 0) for r in range(size)], dtype=np.int32)
    counts = row_counts * nx
    displs = np.zeros(size, dtype=np.int32)
    if size > 1:
        displs[1:] = np.cumsum(counts[:-1])
    recvbuf = np.empty(ny * nx, dtype=np.float32)
else:
    counts = None
    displs = None
    recvbuf = None

if rank == 0:
    comm.Gatherv(sendbuf, [recvbuf, counts, displs, MPI.FLOAT], root=0)
else:
    comm.Gatherv(sendbuf, None, root=0)

if rank == 0:
    mask_full = recvbuf.reshape((ny, nx))
    print("=" * 70)
    print("写入 TRMASK3D")
    for k in range(nz):
        trmask[0, k, :, :] = mask_full
    ds.sync()
    ds.close()

    total_points = ny * nx
    mask_points = int(np.count_nonzero(mask_full))
    mask_ratio = mask_points / total_points * 100.0

    print("=" * 70)
    print("所有 MPI 进程已完成")
    print(f"向量化空间判断耗时: {max_calculation_time:.3f} 秒")
    print(f"总网格点数: {total_points}")
    print(f"掩膜点数: {mask_points}")
    print(f"掩膜比例: {mask_ratio:.2f}%")
    print("=" * 70)