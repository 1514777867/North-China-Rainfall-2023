load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  in_file  = "Swath_Cross_QV_Data.nc"
  out_name = "figure8"
  f = addfile(in_file,"r")

  data_avg_all   = f->qv_time_mean
  percentage_all = f->source_percentage
  valid_time     = f->valid_time
  clats          = f->center_lat
  clons          = f->center_lon
  dates          = chartostring(f->date_string)
  sources        = chartostring(f->source_name)

  dq       = dimsizes(data_avg_all)
  nsources = dq(0)
  nlev     = dq(1)
  npts     = dq(2)
  ndates   = dimsizes(valid_time)
  plevs    = data_avg_all&lev

  print("Input file: "+in_file)
  print("Valid complete dates: "+sum(valid_time)+" / "+ndates)

  all_index = ind(sources.eq."All")
  if (all(ismissing(all_index))) then
    print("[Fatal] Source 'All' not found in input file.")
    exit
  end if
  iall = all_index(0)

  fill_levels = (/ \
    0.1, 0.18, 0.26, 0.34, 0.42, \
    0.5, 0.60, 0.70, 0.80, 0.90, \
    1.0, 1.20, 1.40, 1.60, 1.80, \
    2.0, 2.40, 2.80, 3.20, 3.60, \
    4.0, 4.60, 5.20, 5.80, 6.40, \
    7.0, 7.60, 8.20, 8.80, 9.40, \
    10.0, 11.0, 12.0, 13.0, 14.0, \
    15.0, 16.0, 17.0, 18.0, 19.0, \
    20.0 /)

  label_idx = tointeger(fspan(0.,tofloat(npts-1),7))

wks_type = "pdf"
wks_type@wkWidth      = 4800
wks_type@wkHeight     = 3200
wks_type@wkAntiAlias  = "Off"

wks = gsn_open_wks(wks_type, out_name)
  plots = new(nsources,graphic)

  do s = 0, nsources-1
    data_avg = data_avg_all(s,:,:)

    res = True
    res@gsnDraw  = False
    res@gsnFrame = False

    res@gsnLeftString   = ""
    res@gsnCenterString = ""
    res@gsnRightString  = ""
    res@tiMainString    = ""
    res@tiXAxisString   = ""
    res@tiYAxisString   = ""

    res@gsnPresHgtHeightLabelOn = False

    res@cnFillOn       = True
    res@cnLinesOn      = False
    res@cnLineLabelsOn = False
    res@cnFillPalette  = "WhiteBlueGreenYellowRed"
    res@cnFillMode     = "AreaFill"

    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels = fill_levels

    res@lbLabelBarOn = False

    res@tmXTOn = False
    res@tmYROn = False

    res@vpWidthF  = 0.60
    res@vpHeightF = 0.60

    res@tmYLMode   = "Explicit"
    res@tmYLValues = (/990.,850.,700.,600.,500.,400.,300./)
    res@tmYLLabels = (/"990","850","700","600","500","400","300"/)
    res@tmYLLabelDeltaF = -0.10

    res@tmXBMode   = "Explicit"
    res@tmXBValues = data_avg&npts(label_idx)
    res@tmXBLabels = sprintf("%4.1f",clons(label_idx))+"E~C~"+ \
                     sprintf("%4.1f",clats(label_idx))+"N"
    res@tmXBLabelFontHeightF = 0.012

    plots(s) = gsn_csm_pres_hgt(wks,data_avg,res)

    if (s.ne.iall) then
      perc_avg = percentage_all(s,:,:)

      if (isatt(perc_avg,"long_name")) then
        delete(perc_avg@long_name)
      end if
      if (isatt(perc_avg,"units")) then
        delete(perc_avg@units)
      end if
      if (isatt(perc_avg,"description")) then
        delete(perc_avg@description)
      end if

      res_p = True
      res_p@gsnDraw  = False
      res_p@gsnFrame = False

      res_p@gsnLeftString   = ""
      res_p@gsnCenterString = ""
      res_p@gsnRightString  = ""
      res_p@tiMainString    = ""
      res_p@tiXAxisString   = ""
      res_p@tiYAxisString   = ""

      res_p@cnFillOn       = False
      res_p@cnLinesOn      = True

      res_p@cnLineLabelsOn = True
      res_p@cnInfoLabelOn  = False

      res_p@cnLineColor                = "black"
      res_p@cnLineThicknessF           = 2.5
      res_p@cnLineLabelFontColor       = "black"
      res_p@cnLineLabelBackgroundColor = "white"
      res_p@cnLineLabelInterval        = 1
      res_p@cnLineLabelPlacementMode   = "Constant"
      res_p@cnLineLabelFontHeightF     = 0.010

      res_p@cnLevelSelectionMode = "ExplicitLevels"
      res_p@cnLevels = (/25.,50.,75.,100./)

      plot_p = gsn_csm_contour(wks,perc_avg,res_p)
      overlay(plots(s),plot_p)

      delete([/perc_avg,res_p,plot_p/])
    end if

    delete([/data_avg,res/])
  end do

  pres = True
  pres@gsnMaximize = True

  pres@gsnPanelLabelBar = True
  pres@lbBoxLinesOn = True
  pres@pmLabelBarWidthF   = 0.80
  pres@pmLabelBarHeightF  = 0.05
  pres@lbLabelFontHeightF = 0.012
  pres@lbLabelStride      = 5
  pres@lbTitleOn          = False
  pres@gsnPanelBottom     = 0.08

  pres@gsnPanelInfo = False
  pres@gsnPanelFigureStringsOn = False

  gsn_panel(wks,plots,(/2,3/),pres)

  print("Image saved as: "+out_name+".png")
end
