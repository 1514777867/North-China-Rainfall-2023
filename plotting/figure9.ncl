load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

begin

csv_abs_filename = "Huabei_Area_Avg_QV_g_kg.csv"
csv_perc_filename = "Huabei_Area_Avg_QV_Percentage.csv"

sources = (/"India","Bay_Bengal","South_Sea","Western_Pacific","South_China"/)
nsources = dimsizes(sources)

plevs_abs = (/300,330,360,390,420,450,480,510,540,570,600,630,660,690,720,750,780,810,840,870,900,930,960,989/)
nplevs_abs = dimsizes(plevs_abs)

plevs_perc = (/1000, 950, 900, 850, 800, 750, 700, 650, 600, 550, 500, 450, 400, 350, 300, 250, 200, 150, 100/)
nplevs_perc = dimsizes(plevs_perc)


lines_raw = asciiread(csv_abs_filename, -1, "string")
good_ind = ind(str_strip(lines_raw) .ne. "")
lines = lines_raw(good_ind)
data_lines_all = lines(1:)

if (isStrSubset(data_lines_all(0), ",")) then
      csv_data_all = str_split_csv(data_lines_all, ",", 0)
else
      csv_data_all = str_split_csv(data_lines_all, str_get_tab(), 0)
end if

src_col_stripped = str_strip(csv_data_all(:, 3))
sample_src_idx = ind(src_col_stripped .eq. sources(0))
ntimes_ref = dimsizes(sample_src_idx)

time_labels = new(ntimes_ref, string)
do i = 0, ntimes_ref-1
      d_split = str_split(csv_data_all(sample_src_idx(i), 1), "-/")  
      month_str = sprinti("%02d", toint(d_split(1)))
      day_str     = sprinti("%02d", toint(d_split(2)))
      hour_str_pad = sprinti("%02d", toint(csv_data_all(sample_src_idx(i), 2)))
      time_labels(i) = month_str + "-" + day_str + " " + hour_str_pad  
end do
delete([/lines_raw, good_ind, lines, data_lines_all, csv_data_all, src_col_stripped, sample_src_idx/])

all_data_abs = new((/nsources, nplevs_abs, ntimes_ref/), float)
all_data_abs!1 = "lev"
all_data_abs&lev = plevs_abs
all_data_abs&lev@units = "hPa"   
all_data_abs@_FillValue = -9999.0

all_data_perc = new((/nsources, nplevs_perc, ntimes_ref/), float)
all_data_perc!1 = "lev"
all_data_perc&lev = plevs_perc
all_data_perc&lev@units = "hPa" 
all_data_perc@_FillValue = -9999.0

do s = 0, nsources-1
      source_name = sources(s)

      lines_abs_in = asciiread(csv_abs_filename, -1, "string")
      good_abs = ind(str_strip(lines_abs_in) .ne. "")
      lines_abs = lines_abs_in(good_abs)
      data_lines_abs = lines_abs(1:)

      if (isStrSubset(data_lines_abs(0), ",")) then
            data_abs_raw = str_split_csv(data_lines_abs, ",", 0)
      else
            data_abs_raw = str_split_csv(data_lines_abs, str_get_tab(), 0)
      end if

      src_idx_abs = ind(str_strip(data_abs_raw(:, 3)) .eq. source_name)
      all_data_abs(s, :, :) = (/ transpose(tofloat(data_abs_raw(src_idx_abs, 4:27))) /)

      lines_perc_in = asciiread(csv_perc_filename, -1, "string")
      good_perc = ind(str_strip(lines_perc_in) .ne. "")
      lines_perc = lines_perc_in(good_perc)
      data_lines_perc = lines_perc(1:)

      if (isStrSubset(data_lines_perc(0), ",")) then
            data_perc_raw = str_split_csv(data_lines_perc, ",", 0)
      else
            data_perc_raw = str_split_csv(data_lines_perc, str_get_tab(), 0)
      end if

      src_idx_perc = ind(str_strip(data_perc_raw(:, 3)) .eq. source_name)
      all_data_perc(s, :, :) = (/ transpose(tofloat(data_perc_raw(src_idx_perc, 4:22))) /)

      delete([/lines_abs_in, good_abs, lines_abs, data_lines_abs, data_abs_raw, src_idx_abs, \
                  lines_perc_in, good_perc, lines_perc, data_lines_perc, data_perc_raw, src_idx_perc/])
end do

out_filename = "figure9"
wks = gsn_open_wks("pdf", out_filename)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")  

plots = new(6, graphic)
overlays = new(5, graphic)

res = True
res@gsnDraw  = False   
res@gsnFrame = False   
res@tmXBMode = "Explicit"
res@tmXBValues = ispan(0, ntimes_ref-1, 24)
res@tmXBLabels = time_labels(ispan(0, ntimes_ref-1, 24))
res@tmXBLabelAngleF = 45.0
res@tmXBLabelFontHeightF = 0.015
res@tmXTOn = False
res@tmYROn = False
res@tiXAxisString  = ""     
res@tiYAxisString  = ""    

res_abs = res
res_abs@cnFillOn  = True
res_abs@cnLinesOn = False  
res_abs@cnFillPalette = "WhiteBlueGreenYellowRed"  
res_abs@cnFillMode = "AreaFill"
res_abs@lbLabelBarOn = False    

res_abs@cnLineLabelsOn = False 
res_abs@cnInfoLabelOn = False
res_abs@cnLevelSelectionMode = "ExplicitLevels"

res_abs@cnLevels = (/ \
   0.1,  0.18, 0.26, 0.34, 0.42, \
   0.5,  0.60, 0.70, 0.80, 0.90, \
   1.0,  1.20, 1.40, 1.60, 1.80, \
   2.0,  2.40, 2.80, 3.20, 3.60, \
   4.0,  4.60, 5.20, 5.80, 6.40, \
   7.0,  7.60, 8.20, 8.80, 9.40, \
   10.0, 11.0, 12.0, 13.0, 14.0, \
   15.0, 16.0, 17.0, 18.0, 19.0, \
   20.0 /)

res_abs@trYMaxF = 990.0
res_abs@trYMinF = 300.0
res_abs@tmYLMode   = "Explicit"
res_abs@tmYLValues = (/ 989, 850, 700, 600, 500, 400, 300 /) 
res_abs@tmYLLabels = (/ "990", "850", "700", "600", "500", "400", "300" /)

res_perc = True  
res_perc@gsnDraw   = False
res_perc@gsnFrame = False
res_perc@cnFillOn   = False  
res_perc@cnLinesOn = True    
res_perc@cnLineColor = "black"  
res_perc@cnLineThicknessF = 2.5     
res_perc@cnLineLabelsOn = True  
res_perc@cnLineLabelBackgroundColor = "white"  
res_perc@cnLineLabelInterval = 1     
res_perc@cnLineLabelPlacementMode = "Constant"  
res_perc@cnLevelSelectionMode = "ManualLevels"
res_perc@cnMinLevelValF  = 0.0
res_perc@cnMaxLevelValF  = 100.0
res_perc@cnLevelSpacingF = 25.0
res_perc@cnInfoLabelOn = False

do p = 0, 4
      res_abs@gsnLeftString = "Source: " + sources(p)
      plots(p) = gsn_csm_pres_hgt(wks, all_data_abs(p, :, :), res_abs)
      overlays(p) = gsn_csm_contour(wks, all_data_perc(p, :, :), res_perc)
      overlay(plots(p), overlays(p))
end do

sum_data_abs = dim_sum_n(all_data_abs, 0)
copy_VarMeta(all_data_abs(0, :, :), sum_data_abs) ; 继承坐标属性(lev, time等)

res_sum = res_abs
res_sum@gsnLeftString = "Total Sources (Sum)"
plots(5) = gsn_csm_pres_hgt(wks, sum_data_abs, res_sum)

pres = True
pres@gsnMaximize = True
pres@gsnPanelMainString = "Huabei Area Avg Moisture: Abs(g/kg, Fill) & Contri(%, Line)"  
pres@gsnPanelLabelBar = True          
pres@pmLabelBarWidthF = 0.8        
pres@gsnPanelBottom = 0.08        

pres@lbLabelStride = 5 

gsn_panel(wks, plots, (/2, 3/), pres)

delete(wks)
end