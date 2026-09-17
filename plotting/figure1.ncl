load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

file_era5 = "./ivt29.nc"
file_wrf  = "./wrfout_d01_2023-07-29_00:00:00"
shp_dir   = "./shapefile/"

f_era = addfile(file_era5,"r")
it = 0
g  = 9.81

u = f_era->u(it,:,:,:)  
v = f_era->v(it,:,:,:)
q = f_era->q(it,:,:,:)
plev_hPa = f_era->pressure_level
lat_era = f_era->latitude
lon_era = f_era->longitude

idx = ind(plev_hPa.ge.500 .and. plev_hPa.le.1000)
plev = plev_hPa(idx)*100.0 ; Pa
dp = new((/dimsizes(plev)-1, dimsizes(lat_era), dimsizes(lon_era)/), double)
do k=0, dimsizes(plev)-2
    dp(k,:,:) = plev(k) - plev(k+1)
end do

u_avg = 0.5*(u(idx(0:dimsizes(idx)-2),:,:) + u(idx(1:dimsizes(idx)-1),:,:))
v_avg = 0.5*(v(idx(0:dimsizes(idx)-2),:,:) + v(idx(1:dimsizes(idx)-1),:,:))
q_avg = 0.5*(q(idx(0:dimsizes(idx)-2),:,:) + q(idx(1:dimsizes(idx)-1),:,:))

ivt = sqrt(dim_sum_n(u_avg*q_avg*dp/g, 0)^2 + dim_sum_n(v_avg*q_avg*dp/g, 0)^2)
ivt!0 = "lat"
ivt!1 = "lon"
ivt&lat = lat_era
ivt&lon = lon_era

ivt_plot = ivt(::-1,:)

f_wrf = addfile(file_wrf,"r")
lat_w = f_wrf->XLAT(0,:,:)
lon_w = f_wrf->XLONG(0,:,:)
dims_w = dimsizes(lat_w)
nlat_w = dims_w(0)
nlon_w = dims_w(1)

bnd_npts = nlon_w*2 + nlat_w*2
bnd_lat = new(bnd_npts, float)
bnd_lon = new(bnd_npts, float)
bnd_lat(0:nlon_w-1) = lat_w(0,:)
bnd_lon(0:nlon_w-1) = lon_w(0,:)
bnd_lat(nlon_w:nlon_w+nlat_w-1) = lat_w(:,nlon_w-1)
bnd_lon(nlon_w:nlon_w+nlat_w-1) = lon_w(:,nlon_w-1)
bnd_lat(nlon_w+nlat_w:nlon_w*2+nlat_w-1) = lat_w(nlat_w-1,::-1)
bnd_lon(nlon_w+nlat_w:nlon_w*2+nlat_w-1) = lon_w(nlat_w-1,::-1)
bnd_lat(nlon_w*2+nlat_w:bnd_npts-1) = lat_w(::-1,0)
bnd_lon(nlon_w*2+nlat_w:bnd_npts-1) = lon_w(::-1,0)

wks = gsn_open_wks("png","ERA5_IVT_with_WRF_Domain")

res = True

res@gsnDraw = False
res@gsnFrame = False
res@gsnMaximize = True
res@gsnAddCyclic = False

res@mpProjection = "CylindricalEquidistant"
res@mpLimitMode = "Corners"
res@mpLeftCornerLonF  = 20
res@mpLeftCornerLatF  = -15
res@mpRightCornerLonF = 165
res@mpRightCornerLatF = 60

res@mpFillOn = False
res@mpOutlineOn = True

res@mpGridAndLimbOn = True
res@mpGridLineColor = "gray"

res@mpGridAndLimbOn   = True          
res@mpGridLineColor   = "gray50"      
res@mpGridThicknessF  = 0.5         
res@mpGridSpacingF    = 1.0          
res@mpGridLineDashPattern = 2       
res@tmXBMajorLengthF = 0.008         
res@tmYLMajorLengthF = 0.008

res@tmXBMajorLengthF = 0
res@tmYLMajorLengthF = 0
res@tmXBMinorLengthF = 0
res@tmYLMinorLengthF = 0
res@pmTickMarkDisplayMode = "Always"

res@lbLabelBarOn = True
res@lbOrientation = "vertical"
res@lbBoxEndCapStyle = "TriangleBothEnds"
res@lbBoxLinesOn = True
res@pmLabelBarOrthogonalPosF = 0.02 
res@pmLabelBarWidthF = 0.05         

res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/ 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100 /)
res@cnFillPalette = (/"white","#EFEFEF","#D6E0F0","#9EBAE3","#5C8DD2","#44A790", \
                      "#6AB668","#8ECA5B","#E9E334","#F2962F","#EA6028","#E02925"/)

plot = gsn_csm_contour_map(wks, ivt_plot, res)

shp_files = (/ "Bay_of_Bengal.shp", "South_China_Sea.shp", "India.shp", "South_China_Land.shp", "Taiwan.shp", "Hainan.shp", "huabei.shp" /)

shp_colors = (/ "black", "black", "black", "black", "black", "black", "black"/)       

poly_shp = new(dimsizes(shp_files), graphic)

lnres = True
lnres@gsLineThicknessF = 3.0 

do i = 0, dimsizes(shp_files)-1
    if (isfilepresent(shp_dir + shp_files(i))) then
        lnres@gsLineColor = shp_colors(i)
        poly_shp(i) = gsn_add_shapefile_polylines(wks, plot, shp_dir + shp_files(i), lnres)
    else
        print("警告: 找不到该 Shapefile 文件: " + shp_dir + shp_files(i))
    end if
end do

dom_res = True
dom_res@gsLineColor = "brown"
dom_res@gsLineThicknessF = 5.0
dom_res@gsLineDashPattern = 1 

dum_dom = gsn_add_polyline(wks, plot, bnd_lon, bnd_lat, dom_res)

pres = True
pres@gsLineColor      = "black"
pres@gsLineThicknessF = 1.5   
pres@gsLineDashPattern = 0     

min_lat = -10 
max_lat = 60
min_lon = 20
max_lon = 160

lat_10 = ispan(-20, 60, 15)
dum_lat = new(dimsizes(lat_10), graphic)
do i = 0, dimsizes(lat_10)-1
    dum_lat(i) = gsn_add_polyline(wks, plot, (/min_lon, max_lon/), (/lat_10(i), lat_10(i)/), pres)
end do

lon_10 = ispan(20, 170, 30)
dum_lon = new(dimsizes(lon_10), graphic)
do i = 0, dimsizes(lon_10)-1
    dum_lon(i) = gsn_add_polyline(wks, plot, (/lon_10(i), lon_10(i)/), (/min_lat, max_lat/), pres)
end do

draw(plot)
frame(wks)
print("Plot finished: ERA5_IVT_with_WRF_Domain.png")

end