load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("read_cape_csv")
function read_cape_csv(csv_file:string)
local lines_raw, good_ind, lines, data_lines, csv_data, dims_csv, ncols, cape_str, cape_2d
begin
  lines_raw = asciiread(csv_file,-1,"string")
  good_ind  = ind(str_strip(lines_raw).ne."")
  lines = lines_raw(good_ind)
  data_lines = lines(1:)
  if (isStrSubset(data_lines(0),",")) then
    csv_data = str_split_csv(data_lines,",",0)
  else
    csv_data = str_split_csv(data_lines,str_get_tab(),0)
  end if
  dims_csv = dimsizes(csv_data)
  ncols    = dims_csv(1)
  cape_str = csv_data(:,1:ncols-1)
  cape_str = where(cape_str.eq."NaN","-9999.0",cape_str)
  cape_str = where(cape_str.eq."nan","-9999.0",cape_str)
  cape_str = where(cape_str.eq."NAN","-9999.0",cape_str)
  cape_str = where(str_strip(cape_str).eq."","-9999.0",cape_str)
  cape_2d = tofloat(cape_str)
  cape_2d@_FillValue = -9999.0
  cape_2d = (/ where(cape_2d.le.-9990.0, cape_2d@_FillValue,cape_2d) /)
  cape_2d = (/ where(cape_2d.lt.-1.0e20, cape_2d@_FillValue,cape_2d) /)
  cape_2d = (/ where(isnan_ieee(cape_2d), cape_2d@_FillValue,cape_2d) /)
  cape_2d@_FillValue = -9999.0
  return(cape_2d)
end

undef("fill_missing_cape_as_zero_by_real")
function fill_missing_cape_as_zero_by_real(cape_in:numeric, cape_real_ref:numeric)
local out, fv
begin
  fv = -9999.0
  out = cape_in
  out@_FillValue = fv
  out = (/ where(ismissing(cape_real_ref),fv,out) /)
  out@_FillValue = fv
  out = (/ where((.not.ismissing(cape_real_ref)) .and. ismissing(out),0.0,out) /)
  out@_FillValue = fv
  return(out)
end

undef("read_time_raw")
function read_time_raw(csv_file:string)
local lines_raw, good_ind, lines, data_lines, csv_data, time_raw
begin
  if (.not. fileexists(csv_file)) then
    print("FATAL: 找不到时间文件:")
    print(csv_file)
    exit
  end if
  lines_raw = asciiread(csv_file,-1,"string")
  good_ind  = ind(str_strip(lines_raw).ne."")
  if (all(ismissing(good_ind))) then
    print("FATAL: 时间 CSV 为空:")
    print(csv_file)
    exit
  end if
  lines      = lines_raw(good_ind)
  data_lines = lines(1:)
  if (isStrSubset(data_lines(0),",")) then
    csv_data = str_split_csv(data_lines,",",0)
  else
    csv_data = str_split_csv(data_lines,str_get_tab(),0)
  end if
  time_raw = csv_data(:,0)
  return(time_raw)
end

undef("read_pressure_csv")
function read_pressure_csv(coord_csv:string)
local lines_raw, good_ind, lines, data_lines, csv_data, pressure_hPa
begin
  if (.not. fileexists(coord_csv)) then
    print("FATAL: 找不到气压坐标文件:")
    print(coord_csv)
    exit
  end if
  lines_raw = asciiread(coord_csv,-1,"string")
  good_ind  = ind(str_strip(lines_raw).ne."")
  if (all(ismissing(good_ind))) then
    print("FATAL: 气压坐标文件为空:")
    print(coord_csv)
    exit
  end if
  lines      = lines_raw(good_ind)
  data_lines = lines(1:)
  if (isStrSubset(data_lines(0),",")) then
    csv_data = str_split_csv(data_lines,",",0)
  else
    csv_data = str_split_csv(data_lines,str_get_tab(),0)
  end if
  pressure_hPa = tofloat(csv_data(:,2))
  if (max(pressure_hPa).gt.2000.0) then
    pressure_hPa = pressure_hPa/100.0
  end if
  return(pressure_hPa)
end

undef("write_timeheight_csv")
procedure write_timeheight_csv(out_csv:string, time_raw[*]:string, data2d[*][*]:numeric)
local dims2d, ntimes, nlev, lines, header, it, k, line
begin
  dims2d = dimsizes(data2d)
  ntimes = dims2d(0)
  nlev   = dims2d(1)
  lines = new(ntimes+1,string)
  header = "time"
  do k = 0,nlev-1
    header = header + ",CAPE_lev" + sprinti("%0.2i",k)
  end do
  lines(0) = header
  do it = 0,ntimes-1
    line = time_raw(it)
    do k = 0,nlev-1
      if (ismissing(data2d(it,k))) then
        line = line + ",NaN"
      else
        line = line + "," + sprintf("%.6f",data2d(it,k))
      end if
    end do
    lines(it+1) = line
  end do
  system("rm -f " + out_csv)
  asciiwrite(out_csv,lines)
  print("写出差值 CSV:")
  print(out_csv)
end

undef("create_delta_panel_plot")
function create_delta_panel_plot(wks:graphic, data2d[*][*]:numeric, pressure_hPa[*]:numeric, \
                                 time_values[*]:numeric, tick_values[*]:numeric, tick_labels[*]:string, \
                                 source_title:string, level_min:numeric, level_max:numeric, \
                                 level_spacing:numeric)
local tmp, plot_var, fv, nlevels, nfill, cn_levels, cmap, ncolors, color_idx, res, plot
begin
  fv = -9999.0
  tmp = data2d
  tmp!0 = "time"
  tmp!1 = "lev"
  tmp&time = time_values
  tmp&lev  = pressure_hPa
  tmp&lev@units = "hPa"
  plot_var = tmp(lev|:,time|:)
  plot_var@_FillValue = fv
  plot_var&lev@units  = "hPa"
  plot_var = (/ where(ismissing(plot_var), fv, plot_var) /)
  plot_var@_FillValue = fv
  res = True
  res@gsnDraw  = False
  res@gsnFrame = False
  res@vpWidthF  = 0.30
  res@vpHeightF = 0.30
  res@cnFillOn               = True
  res@cnLinesOn              = False
  res@cnLineLabelsOn         = False
  res@cnInfoLabelOn          = False
  res@cnFillMode              = "RasterFill"
  res@cnRasterSmoothingOn     = True
  res@lbLabelBarOn            = False
  res@cnMissingValFillColor   = "white"
  res@tiMainFontHeightF       = 0.016
  res@tiMainOffsetYF          = -0.015
  nlevels  = toint((tofloat(level_max)-tofloat(level_min)) / \
                   tofloat(level_spacing)) + 1
  cn_levels = fspan(tofloat(level_min),tofloat(level_max),nlevels)
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = cn_levels
  res@cnLabelBarEndStyle   = "IncludeOuterBoxes"
  nfill   = nlevels + 1
  cmap    = gsn_retrieve_colormap(wks)
  ncolors = dimsizes(cmap(:,0))
  color_idx = toint(fspan(2,ncolors-1,nfill))
  res@cnFillColors    = color_idx
  res@gsnSpreadColors = False
  res@tmXBMode             = "Explicit"
  res@tmXBValues           = tick_values
  res@tmXBLabels           = tick_labels
  res@tmXBLabelAngleF      = 45.0
  res@tmXTOn       = False
  res@tmXTLabelsOn = False
  res@trYMinF = 500.0
  res@trYMaxF = 990.0
  res@tmYLMode   = "Explicit"
  res@tmYLValues = (/ 990.0, 850.0, 700.0, 600.0, 500.0/)
  res@tmYLLabels = (/ "990", "850", "700", "600", "500"/)
  res@tmYLMinorOn          = False
  res@tmYLLabelDeltaF      = -0.10
  res@tmYLLabelFontHeightF = 0.012
  res@tmYROn       = False
  res@tmYRLabelsOn = False
  res@gsnPresHgtHeightLabelOn = False
  plot = gsn_csm_pres_hgt(wks,plot_var,res)
  return(plot)
end

begin
  in_dir = "./cape/cape3d_real_source_without/"
  fig_dir = in_dir + "figures_delta_six_sources_2x3_panel_reference_style/"
  system("mkdir -p " + fig_dir)

  coord_csv = in_dir + "huabei_cape3d_height_coordinate.csv"
  real_csv  = in_dir + "huabei_hourly_cape3d_real_wrf_qv_timeheight.csv"

  src_tags = (/ "India", "Bay_Bengal", "South_Sea", "Western_Pacific", "South_China", "All" /)
  src_titles = (/ "India", "Bay of Bengal",  "South Sea", "Western Pacific","South China", "All" /)

  nsrc = dimsizes(src_tags)
  plot_pressure_top = 300.0
  delta_level_min     = 0.0
  delta_level_max     = 1800.0
  delta_level_spacing = 100.0

  cape_real        = read_cape_csv(real_csv)
  time_raw         = read_time_raw(real_csv)
  pressure_hPa_all = read_pressure_csv(coord_csv)

  dims_real = dimsizes(cape_real)
  ntimes    = dims_real(0)
  nlev_all  = dims_real(1)

  if (dimsizes(time_raw).ne.ntimes) then
    print("FATAL: 时间数与 real CAPE 时间数不一致。")
    print("time count = " + dimsizes(time_raw))
    print("CAPE time  = " + ntimes)
    exit
  end if

  if (dimsizes(pressure_hPa_all).ne.nlev_all) then
    print("FATAL: 气压层数与 real CAPE 层数不一致。")
    print("pressure levels = " + dimsizes(pressure_hPa_all))
    print("CAPE levels     = " + nlev_all)
    exit
  end if

  if (max(pressure_hPa_all).lt.10.0) then
    print("WARNING: 气压坐标异常，临时构造 1000--100 hPa。")
    pressure_hPa_all = fspan(1000.0,100.0,nlev_all)
  end if

  keep_lev = ind(pressure_hPa_all.ge.plot_pressure_top)

  if (all(ismissing(keep_lev))) then
    print("FATAL: 没有 pressure >= 300 hPa 的模式层。")
    exit
  end if

  cape_real_keep = cape_real(:,keep_lev)
  delete(cape_real)
  cape_real = cape_real_keep
  delete(cape_real_keep)

  pressure_keep = pressure_hPa_all(keep_lev)
  delete(pressure_hPa_all)
  pressure_hPa_all = pressure_keep
  delete(pressure_keep)

  nlev_plot = dimsizes(pressure_hPa_all)

  print("ntimes = " + ntimes)
  print("nlev all / plotted = " + nlev_all + " / " + nlev_plot)
  print("actual plotted pressure min/max = " + min(pressure_hPa_all) + " / " + max(pressure_hPa_all) + " hPa")

  tick_interval = 24
  tick_idx       = ispan(0,ntimes-1,tick_interval)
  tick_values    = tofloat(tick_idx)

  time_labels_all = new(ntimes,string)

  do i = 0,ntimes-1
    t0 = time_raw(i)

    if (isStrSubset(t0,"_")) then
      t0 = str_sub_str(t0,"_"," ")
    end if

    if (strlen(t0).ge.13) then
      month_str = str_get_cols(t0,5,6)
      day_str   = str_get_cols(t0,8,9)
      hour_str  = str_get_cols(t0,11,12)
      time_labels_all(i) = month_str + "-" + day_str + " " + hour_str
    else
      time_labels_all(i) = t0
    end if
  end do

  tick_labels = time_labels_all(tick_idx)
  time_values = tofloat(ispan(0,ntimes-1,1))

  panel_name = fig_dir + "figure11"

  wks = gsn_open_wks("pdf",panel_name)
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
  plots = new(nsrc,graphic)
  do is = 0,nsrc-1
    print("------------------------------------------------------------")
    print("正在处理: " + src_tags(is))

    without_csv = in_dir + "huabei_hourly_cape3d_real_without_" + src_tags(is) + "_timeheight.csv"

    if ((src_tags(is).eq."All") .and. (.not. fileexists(without_csv))) then

      without_csv_alt = in_dir + "huabei_hourly_cape3d_local_background_timeheight.csv"

      if (fileexists(without_csv_alt)) then
        print("All 使用 local_background CAPE 文件:")
        print(without_csv_alt)
        without_csv = without_csv_alt
      end if
    end if

    if (.not. fileexists(without_csv)) then
      print("FATAL: 找不到 without CAPE 文件:")
      print(without_csv)
      exit
    end if

    cape_without_all = read_cape_csv(without_csv)
    dims_without     = dimsizes(cape_without_all)

    if (dims_without(0).ne.ntimes .or. \
        dims_without(1).ne.nlev_all) then

      print("FATAL: without 文件维度与 real 不一致:")
      print(without_csv)
      print("without dimensions:")
      print(dims_without)
      print("required ntimes = " + ntimes)
      print("required nlev   = " + nlev_all)
      exit
    end if

    cape_without = cape_without_all(:,keep_lev)

    cape_without_plot =  fill_missing_cape_as_zero_by_real(cape_without,cape_real)

    dcape_2d = cape_real-cape_without_plot
    dcape_2d@_FillValue = -9999.0

    dcape_2d = (/ where(dcape_2d.lt.-1.0e20, dcape_2d@_FillValue,dcape_2d) /)
    dcape_2d = (/ where(isnan_ieee(dcape_2d), dcape_2d@_FillValue,dcape_2d) /)
    dcape_2d@_FillValue = -9999.0

    print("DeltaCAPE min/max:")
    print(min(dcape_2d))
    print(max(dcape_2d))

    delta_csv = in_dir + "huabei_hourly_dcape3d_" + src_tags(is) + "_real_minus_without_missing0_fromCSV_timeheight.csv"

    write_timeheight_csv(delta_csv,time_raw,dcape_2d)

    plots(is) = create_delta_panel_plot( \
                  wks,dcape_2d,pressure_hPa_all, \
                  time_values,tick_values,tick_labels, \
                  src_titles(is), \
                  delta_level_min,delta_level_max, \
                  delta_level_spacing)

    delete(cape_without_all)
    delete(cape_without)
    delete(cape_without_plot)
    delete(dcape_2d)
  end do

  pres = True
  pres@gsnMaximize = True
  pres@gsnFrame    = True
  pres@gsnPanelLabelBar = True
  pres@lbTitleFontHeightF = 0.016
  pres@lbBoxLinesOn = True
  pres@lbLabelStride = 6
  pres@lbLabelFontHeightF = 0.012
  pres@pmLabelBarWidthF  = 0.80
  pres@pmLabelBarHeightF = 0.055
  pres@gsnPanelBottom = 0.08
  pres@gsnPanelTop    = 0.93
  pres@gsnPanelXWhiteSpacePercent = 3
  pres@gsnPanelYWhiteSpacePercent = 4
  pres@gsnPanelInfo = False
  pres@gsnPanelFigureStringsOn = False
  gsn_panel(wks,plots,(/2,3/),pres)

  delete(wks)

  print("============================================================")
  if (fileexists(panel_name + ".pdf")) then
    print("绘图完成，PDF 已生成:")
    print(panel_name + ".pdf")
  else
    print("WARNING: 绘图流程结束，但未检测到 PDF:")
    print(panel_name + ".pdf")
    print("请检查终端中在 gsn_panel 之前出现的 FATAL 信息。")
  end if
  print("输出目录:")
  print(fig_dir)
  print("============================================================")
end
