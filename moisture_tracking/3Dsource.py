#!/usr/bin/python
# 3D-binary Tracer Mask Generator

######################################################
Grid_Information_File = 'geo_em.d01.nc'
w_e_points = 1099             # west-east points
s_n_points = 699             # south-north points
b_t_points = 45              # 垂直层数，根据 WRF 设置修改
######################################################

import numpy as np
from netCDF4 import Dataset

Date = "2023-07-21"
Fecha = f"{Date}_00:00:00"

# === 创建输出文件 ===
dataset = Dataset('trmask_d01', 'w', format='NETCDF3_CLASSIC')

# ---------------- 定义维度 ----------------
dataset.createDimension('Time', None)
dataset.createDimension('bottom_top', b_t_points)
dataset.createDimension('south_north', s_n_points)
dataset.createDimension('west_east', w_e_points)
dataset.createDimension('DateStrLen', len(Fecha))

# ---------------- 定义变量 ----------------
XLAT = dataset.createVariable('XLAT', np.float32,('south_north', 'west_east'), zlib=False, fill_value=np.nan)   # 加 fill_value
XLONG = dataset.createVariable('XLONG', np.float32,('south_north', 'west_east'),zlib=False, fill_value=np.nan)
TRMASK3D = dataset.createVariable('TRMASK3D', np.float32, ('Time', 'bottom_top', 'south_north', 'west_east'),zlib=False, fill_value=0.0)
Times = dataset.createVariable('Times', 'S1',('Time', 'DateStrLen'))             # 注意是 S1

# ---------------- 变量属性 ----------------
TRMASK3D.FieldType = 104
TRMASK3D.MemoryOrder = "XYZ"
TRMASK3D.description = "3D Tracer Source Mask (1 for source)"
TRMASK3D.units = ""
TRMASK3D.stagger = ""
TRMASK3D.coordinates = "XLONG XLAT"

XLAT.description = "LATITUDE, SOUTH IS NEGATIVE"
XLAT.units = "degree_north"
XLONG.description = "LONGITUDE, WEST IS NEGATIVE"
XLONG.units = "degree_east"

dataset.TITLE = 'Tracer Moisture Sources Mask Definition (3D)'
dataset.START_DATE = Fecha
dataset.MMINLU = "MODIFIED_IGBP_MODIS_NOAH"
dataset.NUM_LAND_CAT = 21

# ---------------- 读取地理信息 ----------------
grid_info = Dataset(Grid_Information_File)
LAT      = grid_info.variables['XLAT_M'][0, :, :]
LON      = grid_info.variables['XLONG_M'][0, :, :]
LANDMASK = grid_info.variables['LANDMASK'][0, :, :]
grid_info.close()

XLAT[:, :]  = LAT
XLONG[:, :] = LON

# ---------------- 初始化 TRMASK ----------------
TRMASK3D[:, :, :, :] = 0.0

# 写入时间
Times[0, :len(Fecha)] = np.array(list(Fecha), dtype='S1')

# ---------------- 构造 3D 掩膜 ----------------
for k in range(b_t_points):
    TRMASK3D[0, k, :, :] = LANDMASK

# ---------------- 处理边界（按需要） ----------------
TRMASK3D[0, :, 0:10, :]    = 0    # 南边界
TRMASK3D[0, :, :, 0:10]    = 0    # 西边界
TRMASK3D[0, :, 690:699, :] = 0    # 北边界
TRMASK3D[0, :, :, 1090:1099] = 0
print(TRMASK3D)
dataset.close()
print("trmask_d01 创建完成")
