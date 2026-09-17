load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "shapefile_utils.ncl"    

begin

diri_wrf = ".All/"
diri_rain = "./mix_raintr_qbweighted_hourly/"

dates = (/"2023-07-21","2023-07-22","2023-07-23","2023-07-24", \
        "2023-07-25","2023-07-26","2023-07-27","2023-07-28", \
        "2023-07-29","2023-07-30","2023-07-31","2023-08-01"/)

shapefile_path_HB = "./huabei.shp"  

regions = (/"India", "Bay_Bengal", "South_Sea", "Western_Pacific","South_China", "All"/)
nregions = dimsizes(regions)
titles = regions

out_filename = "figure3"


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
print("开始计算各源区及全局(All)的绝对降水量：")

do r = 0, nregions-1
      region = regions(r)
      
      accum_region = new((/nlat, nlon/), float)
      accum_region = 0.0
       
      if (region .ne. "All") then
            varname = "rain_" + region + "_weighted" 
            print("处理区域: " + region)
            do d = 0,dimsizes(dates)-1
                filename = diri_rain + \
                          "mix_raintr_weighted_" + \
                           dates(d) + ".nc"

                print("读取: " + filename)
                f_rain = addfile(filename,"r")
                tmp = f_rain->$varname$
                if(.not.isatt(tmp,"_FillValue")) then
                    tmp@_FillValue = -9999.0
                end if
                replace_ieeenan(tmp,tmp@_FillValue,0)
                tmp = where(ismissing(tmp),0.0,tmp)
                q_2d = dim_sum_n(tmp,2)
                accum_region = accum_region + q_2d
                delete([/f_rain,tmp,q_2d/])
            end do

            
      else
            print("读取 All 区域的 WRF 原始输出数据计算总降水...")
            f_start = addfile(diri_wrf + "wrfout_d01_2023-07-21_00:00:00", "r")
            f_end   = addfile(diri_wrf + "wrfout_d01_2023-08-01_00:00:00", "r")
            
            rainc_start  = wrf_user_getvar(f_start, "TR_RAINC", 0)         
            rainnc_start = wrf_user_getvar(f_start, "TR_RAINNC", 0)      
            rain_total_start = rainc_start + rainnc_start

            rainc_end  = wrf_user_getvar(f_end, "TR_RAINC", 0)                
            rainnc_end = wrf_user_getvar(f_end, "TR_RAINNC", 0)         
            rain_total_end = rainc_end + rainnc_end
            
            accum_region = rain_total_end - rain_total_start        
            accum_region = where(accum_region .lt. 0, 0.0, accum_region)
            
            delete([/f_start, f_end, rainc_start, rainnc_start, rain_total_start, rainc_end, rainnc_end, rain_total_end/])
      end if
       
      total_abs_sum = sum(accum_region)  
      print(region + " -> 全区域降水总绝对值: " + sprintf("%e", total_abs_sum))

      accum_region(0:1, :)   = 0.0  ; 南边界清零
      accum_region(nlat-2:nlat-1, :) = 0.0  ; 北边界清零
      accum_region(:, 0:1)   = 0.0  ; 西边界清零
      accum_region(:, nlon-2:nlon-1) = 0.0  ; 东边界清零

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
res@cnLevels = (/0.1, 10, 25, 50, 100, 250, 400, 600/)

res@cnMissingValFillColor = "white"
res@cnFillMode = "RasterFill"                       
res@lbLabelBarOn = False

res@gsnStringFontHeightF = 0.025

plots = new(nregions, graphic)
lnres = True
lnres@gsLineColor = "black"
lnres@gsLineThicknessF = 3.0

dum_shp = new(1, logical)

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
pres@gsnPanelMainString = "Absolute Precipitation (raintr) over Target Region"  
pres@gsnPanelLabelBar = True          
pres@lbBoxLinesOn           = True     
pres@pmLabelBarWidthF     = 0.8        
pres@pmLabelBarHeightF   = 0.05       
pres@lbLabelFontHeightF  = 0.012     
pres@gsnPanelBottom        = 0.08       

gsn_panel(wks, plots, (/2, 3/), pres)

print("绘图完成！图片已保存至：" + out_filename + ".png")
end