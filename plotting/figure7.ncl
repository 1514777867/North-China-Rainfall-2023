load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

g = 9.81
diri = "./All/"
shpdir = "./shapefile/"

dates = (/ "07-21", "07-22", "07-23", "07-24", "07-25", \
          "07-26", "07-27", "07-28", "07-29", "07-30", "07-31", "08-01"/)
nfiles = dimsizes(dates)

print("开始计算累计 IVT 及平均水汽通量...")

do i = 0, nfiles - 1
    f_name = diri + "wrfout_d01_2023-" + dates(i) + "_00:00:00"
    print("Processing: " + f_name)
    
    if (.not. isfilepresent(f_name)) then
        print("Warning: 文件不存在跳过 - " + f_name)
        continue
    end if

    f = addfile(f_name, "r")
    
    U = wrf_user_unstagger(f->U(0,:,:,:),"X")
    V = wrf_user_unstagger(f->V(0,:,:,:),"Y")
    q = f->QVAPOR(0,:,:,:)
    
    p = wrf_user_getvar(f,"pressure",0) 
    p3d = p * 100                      
    
    dims = dimsizes(p3d)
    nz = dims(0)

    dp = p3d(0:nz-2,:,:) - p3d(1:nz-1,:,:)
    
    iuq_layers = U(0:nz-2,:,:) * q(0:nz-2,:,:) * dp / g
    ivq_layers = V(0:nz-2,:,:) * q(0:nz-2,:,:) * dp / g
    
    iuq = dim_sum_n(iuq_layers, 0)
    ivq = dim_sum_n(ivq_layers, 0)
    
    dp_top = p3d(nz-2,:,:) - p3d(nz-1,:,:) 
    iuq_top = U(nz-1,:,:) * q(nz-1,:,:) * dp_top / g
    ivq_top = V(nz-1,:,:) * q(nz-1,:,:) * dp_top / g
    
    iuq = iuq + iuq_top
    ivq = ivq + ivq_top
    
    ivt_current = sqrt(iuq^2 + ivq^2)

    if (i .eq. 0) then
        ivt_accum = ivt_current
        iuq_accum = iuq
        ivq_accum = ivq
        
        lat = f->XLAT(0,:,:)
        lon = f->XLONG(0,:,:)
        
        copy_VarCoords(U(0,:,:), ivt_accum)
        copy_VarCoords(U(0,:,:), iuq_accum)
        copy_VarCoords(V(0,:,:), ivq_accum)
    else
        ivt_accum = ivt_accum + ivt_current
        iuq_accum = iuq_accum + iuq
        ivq_accum = ivq_accum + ivq
    end if

    delete([/f, U, V, q, p, p3d, dp, iuq_layers, ivq_layers, iuq, ivq, dp_top, iuq_top, ivq_top, ivt_current/])
end do

iuq_mean = iuq_accum / nfiles
ivq_mean = ivq_accum / nfiles

copy_VarCoords(iuq_accum, iuq_mean)
copy_VarCoords(ivq_accum, ivq_mean)

ivt_accum@units="kg m-1 s-1"
print("累积 IVT 的极值范围:")
printMinMax(ivt_accum, 0) 

print("Plotting Cumulative IVT Shading...")
wks = gsn_open_wks("pdf","figure7")

res = True
res@gsnDraw = False  
res@gsnFrame = False

res@sfXArray = lon
res@sfYArray = lat

res@gsnAddCyclic = False
res@gsnMaximize = True

res@mpProjection = "CylindricalEquidistant"
res@mpLimitMode = "Corners"
res@mpLeftCornerLonF = 20
res@mpLeftCornerLatF = -15
res@mpRightCornerLonF = 165
res@mpRightCornerLatF = 60

res@mpFillOn = False
res@mpOutlineOn = True
res@mpGridAndLimbOn = True
res@mpGridLineColor = "gray"

res@tmXBMajorLengthF = 0
res@tmYLMajorLengthF = 0
res@tmXBMinorLengthF = 0
res@tmYLMinorLengthF = 0
res@pmTickMarkDisplayMode = "Always"

res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False

res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/ 3000, 4000, 5000, 6000, 7000, 8000 /) 
res@cnFillPalette = (/"white", "#D6E0F0", "#9EBAE3", "#5C8DD2", "#F2962F", "#EA6028", "#E02925"/)
res@cnFillOpacityF = 0.85 

plot = gsn_csm_contour_map(wks, ivt_accum, res)

print("Plotting Mean IVT Vectors...")
vres = True
vres@gsnDraw  = False
vres@gsnFrame = False
vres@vfXArray = lon
vres@vfYArray = lat

vres@vcGlyphStyle = "CurlyVector"      
vres@vcLineArrowColor = "black"       
vres@vcLineArrowThicknessF = 3.0      

vres@vcRefMagnitudeF = 400.0         
vres@vcRefLengthF    = 0.04          
vres@vcMinDistanceF  = 0.025           
vres@vcRefAnnoString1 = "400 kg m~S~-1~N~ s~S~-1~N~" 

vector = gsn_csm_vector(wks, iuq_mean, ivq_mean, vres)

overlay(plot, vector)

print("Adding Shapefiles...")
shp_paths = (/ shpdir + "bou1_4l.shp", shpdir + "huahb.shp"/)
num_shps = dimsizes(shp_paths)
poly_plots = new(num_shps, graphic)

lnres0 = True
lnres0@gsLineThicknessF = 5.0
lnres0@gsLineColor = "gray" 

lnres = True
lnres@gsLineThicknessF = 6.0
lnres@gsLineColor = "black"

do i = 0, num_shps - 1
  if (isfilepresent(shp_paths(i))) then
    if (i .eq. 0) then
      poly_plots(i) = gsn_add_shapefile_polylines(wks, plot, shp_paths(i), lnres0)
    else
      poly_plots(i) = gsn_add_shapefile_polylines(wks, plot, shp_paths(i), lnres)
    end if
  else
    print("警告: 找不到该 Shapefile 文件: " + shp_paths(i))
  end if
end do

print("Adding Swath Polygon and Centerline...")
pts_lat = (/9, 12, 17, 15, 14, 13, 14, 15, 17, 23, 30, 39, 43/) 
pts_lon = (/47, 60, 74, 85, 90, 110, 115, 124, 128, 129, 124, 117, 115/)

npts    = 100 
x_old   = fspan(0, dimsizes(pts_lat)-1, dimsizes(pts_lat))
x_new   = fspan(0, dimsizes(pts_lat)-1, npts)
clats   = linint1(x_old, pts_lat, False, x_new, 0)
clons   = linint1(x_old, pts_lon, False, x_new, 0)

n_cross    = 5      
half_width = 5.0    

swath_lats = new((/npts, n_cross/), float)
swath_lons = new((/npts, n_cross/), float)

pi_val = 4.0 * atan(1.0)
d2r    = pi_val / 180.0

do p_idx = 0, npts-1
    if (p_idx .eq. 0) then
        dy = clats(1) - clats(0)
        dx = (clons(1) - clons(0)) * cos(clats(0)*d2r)
    else if (p_idx .eq. npts-1) then
        dy = clats(npts-1) - clats(npts-2)
        dx = (clons(npts-1) - clons(npts-2)) * cos(clats(npts-1)*d2r)
    else
        dy = clats(p_idx+1) - clats(p_idx-1)
        dx = (clons(p_idx+1) - clons(p_idx-1)) * cos(clats(p_idx)*d2r)
    end if
    end if

    norm_ang = atan2(dy, dx) + pi_val/2.0
    offsets  = fspan(-half_width, half_width, n_cross)
    
    do j = 0, n_cross-1
        swath_lats(p_idx, j) = clats(p_idx) + offsets(j) * sin(norm_ang)
        swath_lons(p_idx, j) = clons(p_idx) + offsets(j) * cos(norm_ang) / cos(clats(p_idx)*d2r)
    end do
end do

n_poly = 2 * npts + 1
poly_lats = new(n_poly, float)
poly_lons = new(n_poly, float)

poly_lats(0:npts-1) = swath_lats(:, 0)
poly_lons(0:npts-1) = swath_lons(:, 0)
poly_lats(npts:2*npts-1) = swath_lats(::-1, n_cross-1)
poly_lons(npts:2*npts-1) = swath_lons(::-1, n_cross-1)
poly_lats(2*npts) = swath_lats(0, 0)
poly_lons(2*npts) = swath_lons(0, 0)

plres_edge = True
plres_edge@gsLineColor      = "green4"  
plres_edge@gsLineThicknessF = 10.0        

dum_edge_swath = gsn_add_polyline(wks, plot, poly_lons, poly_lats, plres_edge)

plres = True
plres@gsLineColor      = "magenta"     
plres@gsLineThicknessF = 10.0           

pmres_node = True
pmres_node@gsMarkerIndex = 16
pmres_node@gsMarkerSizeF = 0.012       
pmres_node@gsMarkerColor = "black"     

draw(plot)  
frame(wks)

print("Finished: figure7.pdf")

end