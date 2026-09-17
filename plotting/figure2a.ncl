load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "shapefile_utils.ncl"  

begin
    fpath = "./Data/"
    fname = "CN05.1_Pre_2023_daily_025x025.nc"
  
    f = addfile(fpath+fname, "r") 
    time = f->time
    pre = f->pre  
  
    timestr = cd_calendar(time, -2)  
  
    start_index = 201  
    end_index = 212    
  
    print("选择的日期范围: " + timestr(start_index) + " 到 " + timestr(end_index))

    rain_daily = pre(start_index:end_index,:,:)
    rain_total = dim_sum_n_Wrap(rain_daily, 0)
  
    rain_total@units = "mm"
    rain_total@long_name = "Total Precipitation"

    f_hgt = addfile("./era5/Hgt_20230729.nc", "r")
    
    z_packed = f_hgt->z(0,:,:)
    
    z_unpacked = short2flt(z_packed)
    
    z500 = z_unpacked / 98.0665
    copy_VarCoords(z_packed, z500)
    z500@units = "dagpm"

    missing_val = default_fillvalue(typeof(rain_total))
    rain_total@_FillValue = missing_val

    shapefile_dir  = "./shapefile/"
    shp_path1 = shapefile_dir + "china.shp"
    shp_path2 = shapefile_dir + "hainan.shp"

    if (fileexists(shp_path1) .and. fileexists(shp_path2)) then
        print("生成掩膜，使用 shapefile: " + shp_path1 + " 和 " + shp_path2)

        mask_zg3_float = shapefile_mask_data(rain_total, shp_path1, False)
        mask_hnz_float = shapefile_mask_data(rain_total, shp_path2, False)

        if (any(ismissing(mask_zg3_float))) then
            mask_zg3_float = where(ismissing(mask_zg3_float), 0, mask_zg3_float)
        end if
        if (any(ismissing(mask_hnz_float))) then
            mask_hnz_float = where(ismissing(mask_hnz_float), 0, mask_hnz_float)
        end if

        copy_VarCoords(rain_total, mask_zg3_float)
        copy_VarCoords(rain_total, mask_hnz_float)

        mask_combined = mask_zg3_float .or. mask_hnz_float 

        if (any(ismissing(mask_combined))) then
            mask_combined = where(ismissing(mask_combined), 0, mask_combined)
        end if

        copy_VarCoords(rain_total, mask_combined)
        delete([/mask_zg3_float, mask_hnz_float/])
    else
        print("错误: shapefile 不存在 - 检查路径")
        exit
    end if

    rain_total = where(ismissing(rain_total), 0.0, rain_total)
    total_pr_masked = where(mask_combined .eq. 1, rain_total, missing_val)
    copy_VarMeta(rain_total, total_pr_masked)
    total_pr_masked@_FillValue = missing_val
    rain_total = total_pr_masked

    print("===== 掩膜后 =====")
    print("rain_total 有效值范围: " + min(rain_total) + " ~ " + max(rain_total))

    wks = gsn_open_wks("pdf", "figure2a")

    res = True
    res@gsnMaximize = True
    
    res@gsnDraw  = False
    res@gsnFrame = False

    res@gsnAddCyclic = False
    res@cnFillMode = "AreaFill"
    res@cnRasterSmoothingOn = True
    res@cnFillOn = True
    res@cnLinesOn = False
    res@cnLineLabelsOn = False
    res@cnMissingValFillColor = "white"          

    res@lbLabelBarOn = True
    res@lbOrientation = "vertical"
    res@lbBoxLinesOn  = False
    res@pmLabelBarOrthogonalPosF = 0.02
    res@pmLabelBarWidthF = 0.05
    res@lbBoxEndCapStyle = "TriangleBothEnds"
    res@lbBoxLinesOn          = True
    res@pmTickMarkDisplayMode = "Always"
    res@mpFillOn = False
    res@mpOutlineOn = True
    res@mpDataBaseVersion = "MediumRes"
    res@mpDataSetName = "Earth..4"
    res@mpOutlineBoundarySets = "AllBoundaries"
    res@mpNationalLineColor    = "black"
    res@mpGeophysicalLineColor = "black"
    res@tmXBMajorLengthF = 0
    res@tmYLMajorLengthF = 0
    res@tmXBMinorLengthF = 0
    res@tmYLMinorLengthF = 0

    res@mpProjection = "CylindricalEquidistant"
    res@mpLimitMode  = "Corners"
    res@mpLeftCornerLonF = 70
    res@mpLeftCornerLatF = 0
    res@mpRightCornerLonF = 140
    res@mpRightCornerLatF = 60
    res@mpGridAndLimbOn = True
    res@mpGridLineColor = "gray"

    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = (/0.1, 10, 25, 50, 100, 250, 400, 600/)

    cmap_colors = span_color_rgba("WhiteBlueGreenYellowRed", 9)
    cmap_colors(0,:) = (/0.75, 0.75, 0.75, 1.0/)  
    res@cnFillPalette = cmap_colors

    plot = gsn_csm_contour_map(wks, rain_total, res)

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

    lnres = True
    lnres@gsLineColor = "black"
    lnres@gsLineThicknessF = 5.0

    shp_plot  = gsn_add_shapefile_polylines(wks, plot, shapefile_dir + "bou1_4l.shp", lnres)
    shp_plot1  = gsn_add_shapefile_polylines(wks, plot, shapefile_dir + "huabei.shp", lnres)

    draw(plot)
    frame(wks)

    print("绘图完成，请查看 PDF 文件。")
end