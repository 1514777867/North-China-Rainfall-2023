load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
     fdir = "./All/"
       
     fils1 = "wrfout_d01_2023-07-21_00:00:00"    
     fils2 = "wrfout_d01_2023-08-01_00:00:00"       
     fils3 = "wrfout_d01_2023-07-29_00:00:00"      

     a = addfile(fdir + fils1, "r")
     b = addfile(fdir + fils2, "r")
     c = addfile(fdir + fils3, "r")

     time_start = "2023-07-21"
     time_end   = "2023-08-01"


     rainc_start = wrf_user_getvar(a, "RAINC", 0)       
     rainnc_start = wrf_user_getvar(a, "RAINNC", 0)    
     rain_total_start = rainc_start + rainnc_start

     rainc_end = wrf_user_getvar(b, "RAINC", 0)             
     rainnc_end = wrf_user_getvar(b, "RAINNC", 0)         
     rain_total_end = rainc_end + rainnc_end

     total_rain = rain_total_end - rain_total_start       
     copy_VarMeta(rainc_start, total_rain)                        
     lat2d = wrf_user_getvar(a, "XLAT", 0)
     lon2d = wrf_user_getvar(a, "XLONG", 0)

     lat2d!0 = "south_north"
     lat2d!1 = "west_east"
     lon2d!0 = "south_north"
     lon2d!1 = "west_east"

     total_rain@lat2d = lat2d
     total_rain@lon2d = lon2d

     print("===== 总降水量诊断 =====")
     print("最小值 = " + min(total_rain))
     print("最大值 = " + max(total_rain))
     print("缺测值 = " + total_rain@_FillValue)

z3d = wrf_user_getvar(c, "z", 0)                    
p3d = wrf_user_getvar(c, "pressure", 0)        
printVarSummary(z3d)
printVarSummary(p3d)

nlev = dimsizes(z3d(:,0,0))
if (p3d(0,0,0) .gt. p3d(nlev-1,0,0)) then
         print("气压递减，反转垂直层")
         p3d = p3d(::-1,:,:)
         z3d = z3d(::-1,:,:)
end if

z500 = int2p_n(p3d, z3d, 500, 1, 0)        ;
printVarSummary(z500)
dims_z = dimsizes(z500)
if (dimsizes(dims_z) .eq. 3) then
         if (dims_z(0) .eq. 1) then
                  z500 := z500(0,:,:)
         else if (dims_z(2) .eq. 1) then
                  print("警告: 插值结果仍包含垂直层，请检查输入数据")
                  exit
         else
                  print("错误: 无法识别的三维形状: " + dims_z)
                  exit
         end if
         end if
end if

if (dimsizes(dimsizes(z500)) .ne. 2) then
         print("错误: z500 不是二维数组")
         exit
end if

z500@lat2d = lat2d
z500@lon2d = lon2d
   z500 = z500/10
print("===== 500 hPa 高度诊断 =====")
print("最小值 = " + min(z500) + " m")
print("最大值 = " + max(z500) + " m")
print("最终维度: " + dimsizes(z500))
     shapefile_dir = "./shapefile/"

     filename = "total_precip_" + time_start + "_to_" + time_end + "_china_mask.png"
     wks = gsn_open_wks("pdf", filename)
     gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

     res = True
     res@gsnMaximize = True

     res@cnFillMode = "AreaFill"
     res@cnRasterSmoothingOn = True
     res@cnFillOn = True
     res@cnLinesOn = False
     res@cnLineLabelsOn = False
     res@cnMissingValFillColor = "white"                     
     res@lbLabelBarOn = True
     res@lbOrientation = "vertical"
     res@lbBoxLinesOn     = False
     res@pmLabelBarOrthogonalPosF = 0.02
     res@pmLabelBarWidthF = 0.05
     res@lbBoxEndCapStyle = "TriangleBothEnds"
     res@lbBoxLinesOn                       = True
     res@pmTickMarkDisplayMode = "Always"
     res@mpFillOn = False
     res@mpOutlineOn = True
     res@mpDataBaseVersion = "MediumRes"
     res@mpDataSetName = "Earth..4"
     res@mpOutlineBoundarySets = "AllBoundaries"
     res@mpNationalLineColor         = "black"
     res@mpGeophysicalLineColor = "black"
     res@tmXBMajorLengthF = 0
     res@tmYLMajorLengthF = 0
     res@tmXBMinorLengthF = 0
     res@tmYLMinorLengthF = 0
     res@mpProjection = "CylindricalEquidistant"
     res@mpLimitMode     = "Corners"
     res@mpLeftCornerLonF = 70
     res@mpLeftCornerLatF = 0
     res@mpRightCornerLonF = 140
     res@mpRightCornerLatF = 60

     res@mpGridAndLimbOn = True
     res@mpGridLineColor = "gray"

     res@cnLevelSelectionMode = "ExplicitLevels"
     res@cnFillMode = "RasterFill"
     res@cnLevels                              = (/0.1,10,25,50,100,250,400,600/)

     plot = gsn_csm_contour_map(wks, total_rain, res)

     cres = True
     cres@gsnDraw = False
     cres@gsnFrame = False
     cres@gsnAddCyclic = False
     cres@gsnLeftString = ""
     cres@gsnRightString = ""

     cres@cnFillOn = False
     cres@cnLinesOn = True
     cres@cnLineColor = "black"
     cres@cnLineThicknessF = 3.0
     cres@cnLevelSelectionMode = "ManualLevels"
     cres@cnMinLevelValF = 540
     cres@cnMaxLevelValF = 600
     cres@cnLevelSpacingF = 2
     cres@cnLineLabelsOn = True
     cres@cnLineLabelBackgroundColor = "transparent"
     cres@cnLineLabelFontHeightF = 0.01
     cres@cnLineLabelFontColor = "black"
     cres@cnInfoLabelOn = False

     contour_z = gsn_csm_contour(wks, z500, cres)
     overlay(plot, contour_z)

     cres_bold = True
     cres_bold@gsnDraw = False
     cres_bold@gsnFrame = False
     cres_bold@gsnAddCyclic = False
     cres_bold@gsnLeftString = ""
     cres_bold@gsnRightString = ""

     cres_bold@cnFillOn = False
     cres_bold@cnLinesOn = True
     cres_bold@cnLineColor = "yellow"
     cres_bold@cnLineThicknessF = 8.0
     cres_bold@cnLevelSelectionMode = "ExplicitLevels"
     cres_bold@cnLevels = (/588/)
     cres_bold@cnLineLabelsOn = True
     cres_bold@cnLineLabelString = "588"
     cres_bold@cnLineLabelFontHeightF = 0.012
     cres_bold@cnLineLabelFontColor = "black"
     cres_bold@cnInfoLabelOn = False

     contour_bold = gsn_csm_contour(wks, z500, cres_bold)
     overlay(plot, contour_bold)

        shp_paths = (/ shapefile_dir + "bou1_4l.shp", shapefile_dir + "huabei.shp"/)

        lnres = True
        lnres@gsLineColor     = "black"

        num_shps = dimsizes(shp_paths)
        shp_plots = new(num_shps, graphic)

        do i = 0, num_shps - 1
            if (isfilepresent(shp_paths(i))) then
                 shp_plots(i) = gsn_add_shapefile_polylines(wks, plot, shp_paths(i), lnres)
            else
                 print("警告: 找不到该 Shapefile 文件: " + shp_paths(i))
            end if
        end do

        draw(plot)
        frame(wks)

     print("绘图完成，文件已保存至: " + filename)

end
