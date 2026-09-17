load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "shapefile_utils.ncl"    

begin

diri_wrf = "./Western_Pacific/"
diri_qv   = "./mix_qvtr_weighted_hourly/"

dates = (/"2023-07-21","2023-07-22","2023-07-23","2023-07-24", \
               "2023-07-25","2023-07-26","2023-07-27","2023-07-28", \
               "2023-07-29","2023-07-30","2023-07-31","2023-08-01"/)

shapefile_path_HB = "./huabei.shp"  

regions = (/"India", "Bay_Bengal", "South_Sea", "Western_Pacific","South_China", "All"/)
nregions = dimsizes(regions)
titles = regions

out_filename = "figure4"

f_ref = addfile(diri_wrf + "wrfout_d01_2023-07-21_00:00:00", "r")
lat2d = wrf_user_getvar(f_ref, "XLAT", 0)
lon2d = wrf_user_getvar(f_ref, "XLONG", 0)

dims_lat2d = dimsizes(lat2d)
nlat = dims_lat2d(0)
nlon = dims_lat2d(1)

plot_data = new((/nregions, nlat, nlon/), float)
plot_data = 0.0
plot_data@_FillValue = -9999.0

print("==============================================")
print("开始计算各水汽源区及 All 区域的绝对水汽值：")

do r = 0, nregions-1
      region = regions(r)
       
      accum_region = new((/nlat, nlon/), float)
      accum_region = 0.0

      if (region .ne. "All") then
            varname = "qv_" + region + "_weighted"
            print("处理区域: " + region)
             
            do d = 0, dimsizes(dates)-1
                  f_qv = addfile(diri_qv + "mix_qvtr_weighted_" + dates(d) + ".nc", "r")
                  q_3d = f_qv->$varname$(0,:,:,:) * 1000.0
                   
                  if(.not.isatt(q_3d,"_FillValue")) then
                        q_3d@_FillValue = -9999.0
                  end if
                  replace_ieeenan(q_3d, q_3d@_FillValue, 0)
                   
                  q_2d = dim_sum_n_Wrap(q_3d, 0)
                   
                  q_2d = where(ismissing(q_2d), 0.0, q_2d)
               
                  accum_region = accum_region + q_2d
                  delete([/f_qv, q_3d, q_2d/])
            end do
      else
            print("处理区域: All (计算前 5 个源区之和)")
            accum_region = dim_sum_n(plot_data(0:nregions-2, :, :), 0)
      end if
       
      total_abs_sum = sum(accum_region)  
      print(region + " -> 全区域水汽总绝对值: " + sprintf("%e", total_abs_sum))

      accum_region(0:1, :)   = 0.0  
      accum_region(nlat-2:nlat-1, :) = 0.0  
      accum_region(:, 0:1)   = 0.0  
      accum_region(:, nlon-2:nlon-1) = 0.0  

      plot_data(r, :, :) = accum_region
       
      delete([/accum_region/])
end do
print("==============================================")

wks = gsn_open_wks("pdf", out_filename)  

res = True
res@gsnDraw   = False    
res@gsnFrame = False    
res@gsnAddCyclic = False

res@cnFillPalette = "WhiteBlueGreenYellowRed" 

res@mpProjection = "CylindricalEquidistant"
res@mpLimitMode   = "Corners"
res@mpLeftCornerLonF   = 70.0     
res@mpLeftCornerLatF   = 0.0       
res@mpRightCornerLonF = 140.0     
res@mpRightCornerLatF = 60.0       
res@mpDataBaseVersion = "MediumRes"
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "National"
res@mpFillOn = False

res@tmXTOn = False
res@tmYROn = False
res@mpGridAndLimbOn = True
res@mpGridLineDashPattern = 2
res@mpGridLineColor = "gray50"

res@sfXArray = lon2d
res@sfYArray = lat2d

res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False

res@cnLevelSelectionMode = "ExplicitLevels"   
res@cnLevels             = (/50, 100, 200, 400, 700, 1100, 1500, 2000, 2500, 3000, 3500, 4000, 4500/) 
res@cnMissingValFillColor = "white"

res@cnFillMode = "RasterFill"                       
res@lbLabelBarOn = False

res@gsnStringFontHeightF = 0.025

plots = new(nregions, graphic)
dum_shp = new(1, logical)  

lnres = True
lnres@gsLineColor = "black"
lnres@gsLineThicknessF = 3.0

do p = 0, nregions-1
      res@gsnLeftString = titles(p)
      plots(p) = gsn_csm_contour_map(wks, plot_data(p,:,:), res)
       
      if (fileexists(shapefile_path_HB)) then
            str = unique_string("shp")
            dum_shp@$str$ = gsn_add_shapefile_polylines(wks, plots(p), shapefile_path_HB, lnres)
      end if
end do

pres = True
pres@gsnMaximize = True
pres@gsnPanelLabelBar = True          

pres@lbBoxLinesOn           = True     
pres@pmLabelBarWidthF     = 0.8        
pres@pmLabelBarHeightF   = 0.05       
pres@lbLabelFontHeightF = 0.012     
pres@gsnPanelBottom        = 0.08       

gsn_panel(wks, plots, (/2, 3/), pres)

print("绘图完成！图片已保存至：" + out_filename + ".pdf")
end