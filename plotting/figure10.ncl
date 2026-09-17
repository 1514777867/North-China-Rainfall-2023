load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("clean_num_string")
function clean_num_string(str_in[*]:string)
local str_out
begin
  str_out = str_in
  str_out = where(str_out.eq."NaN", "-9999.0", str_out)
  str_out = where(str_out.eq."nan", "-9999.0", str_out)
  str_out = where(str_out.eq."NAN", "-9999.0", str_out)
  str_out = where(str_strip(str_out).eq."", "-9999.0", str_out)
  return(str_out)
end

undef("read_pressure_csv")
function read_pressure_csv(coord_csv:string)
local lines_raw, good_ind, lines, data_lines, csv_data, pressure_hPa
begin

  lines_raw = asciiread(coord_csv,-1,"string")
  good_ind  = ind(str_strip(lines_raw).ne."")

  lines      = lines_raw(good_ind)
  data_lines = lines(1:)

  if (isStrSubset(data_lines(0),",")) then
    csv_data = str_split_csv(data_lines,",",0)
  else
    csv_data = str_split_csv(data_lines,str_get_tab(),0)
  end if

  pressure_hPa = tofloat(csv_data(:,2))

  if (max(pressure_hPa).gt.2000.0) then
    pressure_hPa = pressure_hPa / 100.0
  end if

  pressure_hPa@units = "hPa"
  return(pressure_hPa)
end

undef("read_source_thetae_matrix")
function read_source_thetae_matrix(csv_file:string, source_name:string)
local lines_raw, good_ind, lines, data_lines, csv_data, dims_csv, \
      time_idx_all, lev_idx_all, src_all, theta_str, theta_all, \
      nt, nlev, out, idx, nidx, ii, ir, it, iz, fv
begin
  fv = -9999.0

  lines_raw = asciiread(csv_file, -1, "string")
  good_ind  = ind(str_strip(lines_raw).ne."")

  lines = lines_raw(good_ind)

  data_lines = lines(1:)

  if (isStrSubset(data_lines(0), ",")) then
    csv_data = str_split_csv(data_lines, ",", 0)
  else
    csv_data = str_split_csv(data_lines, str_get_tab(), 0)
  end if

  dims_csv = dimsizes(csv_data)

  time_idx_all = toint(csv_data(:,0))
  lev_idx_all  = toint(csv_data(:,2))
  src_all      = csv_data(:,4)

  theta_str = clean_num_string(csv_data(:,5))
  theta_all = tofloat(theta_str)
  theta_all@_FillValue = fv

  theta_all = (/ where(theta_all.le.-9990.0, fv, theta_all) /)
  theta_all = (/ where(theta_all.lt.-1.0e20, fv, theta_all) /)
  theta_all = (/ where(isnan_ieee(theta_all), fv, theta_all) /)
  theta_all@_FillValue = fv

  nt   = max(time_idx_all) + 1
  nlev = max(lev_idx_all) + 1

  out = new((/nt,nlev/), float, fv)
  out@_FillValue = fv

  idx = ind(src_all.eq.source_name)

  nidx = dimsizes(idx)

  do ii = 0, nidx-1
    ir = idx(ii)
    it = time_idx_all(ir)
    iz = lev_idx_all(ir)

    if (.not. ismissing(theta_all(ir))) then
      out(it,iz) = theta_all(ir)
    end if
  end do

  return(out)
end

undef("read_real_all_thetae_matrix")
function read_real_all_thetae_matrix(csv_file:string, mode:string)
local lines_raw, good_ind, lines, data_lines, csv_data, dims_csv, \
      time_idx_all, lev_idx_all, theta_str, theta_all, \
      nt, nlev, out, nrow, i, it, iz, col_id, fv
begin
  fv = -9999.0

  lines_raw = asciiread(csv_file, -1, "string")
  good_ind  = ind(str_strip(lines_raw).ne."")

  lines = lines_raw(good_ind)

  data_lines = lines(1:)

  if (isStrSubset(data_lines(0), ",")) then
    csv_data = str_split_csv(data_lines, ",", 0)
  else
    csv_data = str_split_csv(data_lines, str_get_tab(), 0)
  end if

  dims_csv = dimsizes(csv_data)

  if (mode.eq."All_original") then
    col_id = 4
  else
    col_id = 5
  end if

  time_idx_all = toint(csv_data(:,0))
  lev_idx_all  = toint(csv_data(:,2))

  theta_str = clean_num_string(csv_data(:,col_id))
  theta_all = tofloat(theta_str)
  theta_all@_FillValue = fv

  theta_all = (/ where(theta_all.le.-9990.0, fv, theta_all) /)
  theta_all = (/ where(theta_all.lt.-1.0e20, fv, theta_all) /)
  theta_all = (/ where(isnan_ieee(theta_all), fv, theta_all) /)
  theta_all@_FillValue = fv

  nt   = max(time_idx_all) + 1
  nlev = max(lev_idx_all) + 1

  out = new((/nt,nlev/), float, fv)
  out@_FillValue = fv

  nrow = dimsizes(time_idx_all)

  do i = 0, nrow-1
    it = time_idx_all(i)
    iz = lev_idx_all(i)

    if (.not. ismissing(theta_all(i))) then
      out(it,iz) = theta_all(i)
    end if
  end do

  out@units = "K"
  return(out)
end

undef("read_time_labels_from_source_csv")
function read_time_labels_from_source_csv(csv_file:string)
local lines_raw, good_ind, lines, data_lines, csv_data, \
      time_idx_all, time_label_all, nt, time_labels, nrow, i, it
begin

  lines_raw = asciiread(csv_file, -1, "string")
  good_ind  = ind(str_strip(lines_raw).ne."")
  lines     = lines_raw(good_ind)
  data_lines = lines(1:)

  if (isStrSubset(data_lines(0), ",")) then
    csv_data = str_split_csv(data_lines, ",", 0)
  else
    csv_data = str_split_csv(data_lines, str_get_tab(), 0)
  end if

  time_idx_all   = toint(csv_data(:,0))
  time_label_all = csv_data(:,1)

  nt = max(time_idx_all) + 1
  time_labels = new(nt, string)

  do i = 0, nt-1
    time_labels(i) = ""
  end do

  nrow = dimsizes(time_idx_all)

  do i = 0, nrow-1
    it = time_idx_all(i)

    if (time_labels(it).eq."") then
      time_labels(it) = time_label_all(i)
    end if
  end do

  return(time_labels)
end

undef("create_thetae_pres_panel_plot")
function create_thetae_pres_panel_plot(wks:graphic, \
                                       data2d[*][*]:numeric, \
                                       pressure_hPa[*]:numeric, \
                                       time_values[*]:numeric, \
                                       tick_values[*]:numeric, \
                                       tick_labels[*]:string, \
                                       source_title:string, \
                                       thetae_levels[*]:numeric, \
                                       show_own_labelbar:logical)
local tmp, plot_var, fv, nlevels, nfill, cn_levels, cmap, ncolors, \
      color_idx, res, plot
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
  plot_var = (/ where(plot_var.lt.-1.0e20, fv, plot_var) /)
  plot_var = (/ where(isnan_ieee(plot_var), fv, plot_var) /)
  plot_var@_FillValue = fv

  res = True
  res@gsnDraw  = False
  res@gsnFrame = False

  res@vpWidthF  = 0.30
  res@vpHeightF = 0.25

  res@cnFillOn          = True
  res@cnLinesOn         = False
  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn     = False
  res@cnFillMode        = "RasterFill"
  res@cnSmoothingOn     = False
  res@lbLabelBarOn      = True
  res@cnMissingValFillColor = "white"

  res@lbOrientation = "horizontal"
  res@pmLabelBarDisplayMode = "Always"
  res@pmLabelBarSide = "Bottom"
  res@pmLabelBarWidthF  = 0.25
  res@pmLabelBarHeightF = 0.030
  res@pmLabelBarOrthogonalPosF = 0.08

  res@lbBoxLinesOn = True
  res@lbLabelFontHeightF = 0.0065
  res@lbLabelAutoStride = False
  res@lbLabelStride = 10

  cn_levels = tofloat(thetae_levels)
  nlevels   = dimsizes(cn_levels)

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = cn_levels
  res@cnLabelBarEndStyle   = "IncludeOuterBoxes"

  nfill   = nlevels + 1
  cmap    = gsn_retrieve_colormap(wks)
  ncolors = dimsizes(cmap(:,0))

  color_idx = toint(fspan(2, ncolors-1, nfill))
  res@cnFillColors    = color_idx
  res@gsnSpreadColors = False

  res@tmXBMode        = "Explicit"
  res@tmXBValues      = tick_values
  res@tmXBLabels      = tick_labels
  res@tmXBLabelAngleF = 45.0
  res@tmXTOn       = False
  res@tmXTLabelsOn = False
  res@trYMinF = 500.0
  res@trYMaxF = 990.0

  res@tmYLMode   = "Explicit"
  res@tmYLValues = (/ 990.0, 850.0, 700.0, 600.0, 500.0 /)
  res@tmYLLabels = (/ "990", "850", "700", "600", "500" /)
  res@tmYLMinorOn          = False
  res@tmYLLabelDeltaF      = -0.10
  res@tmYLLabelFontHeightF = 0.012
  res@tmYROn       = False
  res@tmYRLabelsOn = False

  res@gsnPresHgtHeightLabelOn = False

  plot = gsn_csm_pres_hgt(wks, plot_var, res)

  return(plot)
end

;===============================================================
begin
  print("============================================================")
  print("开始绘制 5 个水汽源区 + Real 的 thetae_i 2x3 Panel")
  print("前五张：thetae_i 填色，使用源区等间距色阶")
  print("最后一张 Real：thetae_real 填色，使用 Real 等间距色阶")
  print("纵坐标保持 500--990 hPa")
  print("============================================================")

  in_dir = "./"

  src_csv  = in_dir + "huabei_hourly_thetae_i_sources_timeheight.csv"
  real_csv = in_dir + "huabei_hourly_thetae_i_real_and_all_timeheight.csv"
  coord_csv = in_dir + "huabei_cape3d_height_coordinate.csv"

  fig_dir = in_dir + "figures_thetae_i_pressure_2x3_panel_each_cb_no_w_fixed_labels/"
  system("mkdir -p " + fig_dir)

  panel_name = fig_dir + "figure10"

  src_tags = (/ "India", "Bay_Bengal", "South_Sea", "Western_Pacific", "South_China", "All" /)

  src_titles = (/ "India", "Bay of Bengal", "South Sea", "Western Pacific", "South China", "All" /)

  nsrc = dimsizes(src_tags)

  thetae_levels_src  = fspan(305.0, 345.0, 41)  
  thetae_levels_real = fspan(310.0, 360.0, 51)  

  thetae_test      = read_source_thetae_matrix(src_csv, "India")
  time_raw         = read_time_labels_from_source_csv(src_csv)
  pressure_hPa_all = read_pressure_csv(coord_csv)

  dims_thetae = dimsizes(thetae_test)
  ntimes      = dims_thetae(0)
  nlev_all    = dims_thetae(1)

  delete(thetae_test)

  if (max(pressure_hPa_all).lt.10.0) then
    print("WARNING: 气压坐标异常，临时构造 1000--100 hPa。")
    pressure_hPa_all = fspan(1000.0, 100.0, nlev_all)
  end if

  keep_lev = ispan(0, nlev_all-1, 1)

  nlev_plot = dimsizes(pressure_hPa_all)

  print("ntimes = " + ntimes)
  print("nlev all / plotted = " + nlev_all + " / " + nlev_plot)
  print("pressure coordinate min/max = " + min(pressure_hPa_all) + " / " + max(pressure_hPa_all) + " hPa")

  tick_interval = 24
  tick_idx       = ispan(0, ntimes-1, tick_interval)
  tick_values    = tofloat(tick_idx)
  time_labels_all = new(ntimes, string)

  do i = 0, ntimes-1
    t0 = time_raw(i)

    if (isStrSubset(t0, "_")) then
      t0 = str_sub_str(t0, "_", " ")
    end if

    time_labels_all(i) = t0
  end do

  tick_labels = time_labels_all(tick_idx)
  time_values = tofloat(ispan(0, ntimes-1, 1))

wks_type = "pdf"


wks = gsn_open_wks(wks_type, panel_name)
gsn_define_colormap(wks, "WhiteBlueGreenYellowRed")
  plots = new(nsrc, graphic)

  do is = 0, nsrc-1

    print("------------------------------------------------------------")
    print("正在处理: " + src_tags(is))

    if (src_tags(is).eq."Real") then
      thetae_2d_all = read_real_all_thetae_matrix(real_csv, "Real")
    else
      thetae_2d_all = read_source_thetae_matrix(src_csv, src_tags(is))
    end if

    dims_now = dimsizes(thetae_2d_all)

    if (dims_now(0).ne.ntimes .or. dims_now(1).ne.nlev_all) then
      print("FATAL: 当前 thetae 数据维度不一致:")
      print(src_tags(is))
      print(dims_now)
      print("required ntimes = " + ntimes)
      print("required nlev   = " + nlev_all)
      exit
    end if

    thetae_2d = thetae_2d_all(:,keep_lev)
    thetae_2d@_FillValue = -9999.0
    thetae_2d = (/ where(thetae_2d.lt.-1.0e20, thetae_2d@_FillValue, thetae_2d) /)
    thetae_2d = (/ where(isnan_ieee(thetae_2d), thetae_2d@_FillValue, thetae_2d) /)
    thetae_2d@_FillValue = -9999.0


    print(src_tags(is) + " thetae min/max:")
    print(min(thetae_2d))
    print(max(thetae_2d))


    if (src_tags(is).eq."Real" .or. src_tags(is).eq."South_China") then
      plots(is) = create_thetae_pres_panel_plot( \
                    wks, thetae_2d, pressure_hPa_all, \
                    time_values, tick_values, tick_labels, \
                    src_titles(is), \
                    thetae_levels_real, \
                    True)
    else
      plots(is) = create_thetae_pres_panel_plot( \
                    wks, thetae_2d, pressure_hPa_all, \
                    time_values, tick_values, tick_labels, \
                    src_titles(is), \
                    thetae_levels_src, \
                    False)
    end if

    delete(thetae_2d_all)
    delete(thetae_2d)

  end do

  pres = True
  pres@gsnMaximize = True
  pres@gsnPanelMainFontHeightF = 0.017
  pres@gsnPanelLabelBar = False
  pres@gsnPanelBottom = 0.05
  pres@gsnPanelTop    = 0.93
  pres@gsnPanelXWhiteSpacePercent = 4
  pres@gsnPanelYWhiteSpacePercent = 12
  pres@gsnPanelInfo = False
  pres@gsnPanelFigureStringsOn = False

  gsn_panel(wks, plots, (/2,3/), pres)

  print("绘图完成:")

end