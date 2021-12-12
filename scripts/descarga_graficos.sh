#!/bin/sh

rm ./*.gif
rm ./*.jpg
rm ./*.pdf
rm ./*.png

# Ruta a los scrips para correr en python
# Hay que correr esto desde la carpeta raiz del repositorio, 
enlace=./scripts/

anio=$(date -d "$date" +"%Y")
mes1=$(date -d "$date -3 month" +"%m")
anio1=$(date -d "$date -3 month" +"%Y")
mes2=$(date -d "$date -2 month" +"%m")
anio2=$(date -d "$date -2 month" +"%Y")
mes3=$(date -d "$date -1 month" +"%m")
anio3=$(date -d "$date -1 month" +"%Y")

# ultimo día del mes. Mes 3 es el anterior.
dfm1=$(cal $(date -d "$date -3 month" +"%m %Y") | awk 'NF {DAYS = $NF}; END {print DAYS}')
dfm2=$(cal $(date -d "$date -2 month" +"%m %Y") | awk 'NF {DAYS = $NF}; END {print DAYS}')
dfm3=$(cal $(date -d "$date -1 month" +"%m %Y") | awk 'NF {DAYS = $NF}; END {print DAYS}')

#current month
cumes=$(date -d "$date" +"%m")

# De https://stackoverflow.com/questions/36757864/how-to-get-the-latest-date-for-a-specific-day-of-the-week-in-bash
# requires bash 4.x and GNU date
last_kday() {
  local kday=$1
  local -A numbers=([sunday]=0   [monday]=1 [tuesday]=2 [wednesday]=3
                    [thursday]=4 [friday]=5 [saturday]=6)
  if [[ $kday == *day ]]; then
    kday=${numbers[${kday,,}]}
  elif [[ $kday != [0-6] ]]; then
    echo >&2 "Usage: last_kday weekday"
    return 1
  fi

  local today=$(date +%w)
  local days_ago=$(( today - kday ))
  if (( days_ago < 0 )); then let days_ago+=7; fi
  date -d "$days_ago days ago" +%d
}

# Prono IOD 
martes=$(last_kday tuesday)


#Imagen SOI (fija)
wget -O SOI.gif http://www.cpc.ncep.noaa.gov/products/CDB/Tropics/figt1.gif

#Imagen SOI zoom (fija)
wget -U "Mozzila" -O SOI_zoom.png http://www.bom.gov.au/climate/enso/monitoring/soi30.png

#Regiones SOI (fija)
wget -O SOI_regiones.png https://www.climate.gov/sites/default/files/styles/inline_all/public/Fig1_ENSOindices_SOI_610.png

#Imagen Series Niño Sectores 20 años (fija)
wget -O NINO_20.gif http://www.cpc.ncep.noaa.gov/products/CDB/Tropics/figt5.gif

#Imagen Sectores Niño (fija)
wget -O nino_regions.jpg http://www.cpc.ncep.noaa.gov/products/analysis_monitoring/ensostuff/ninoareas_c.jpg

#Imagen Series Niño Sectores 1 año (fija)
wget -O NINO_1.gif http://www.cpc.ncep.noaa.gov/products/analysis_monitoring/enso_advisory/figure02.gif

#Imagen TSM y Anomalía TSM mensual (fija)
wget -O TSM_M1.gif http://www.cpc.ncep.noaa.gov/products/CDB/CDB_Archive_html/bulletin_$mes1$anio1/Tropics/figt18.gif
wget -O TSM_M2.gif http://www.cpc.ncep.noaa.gov/products/CDB/CDB_Archive_html/bulletin_$mes2$anio2/Tropics/figt18.gif
wget -O TSM_M3.gif http://www.cpc.ncep.noaa.gov/products/CDB/CDB_Archive_html/bulletin_$mes3$anio3/Tropics/figt18.gif

#Imagen Anomalía TSM mensual más actual (fija)
wget http://www.cpc.ncep.noaa.gov/products/analysis_monitoring/lanina/enso_evolution-status-fcsts-web.pdf
qpdf enso_evolution-status-fcsts-web.pdf --pages enso_evolution-status-fcsts-web.pdf 7 -- tmp.pdf
#pdftk enso_evolution-status-fcsts-web.pdf cat 7 output tmp.pdf
pdfcrop --margins '-115 -180 -115 -25' tmp.pdf Actual_TSM_Mon.pdf 
convert -density 300 -trim Actual_TSM_Mon.pdf -quality 100 Actual_TSM_Mon.jpg
rm Actual_TSM_Mon.pdf

#Imagen TSM sub-superficial (fija)
qpdf enso_evolution-status-fcsts-web.pdf --pages enso_evolution-status-fcsts-web.pdf 12 -- tmp.pdf
pdfcrop --margins '-25 -180 -320 -175' tmp.pdf Actual_TSM_Subsup.pdf
pdfcrop --margins '-425 -145 -17 -30' tmp.pdf TSM_Subsup.pdf

convert -density 300 -trim Actual_TSM_Subsup.pdf -quality 100 Actual_TSM_Subsup.jpg
convert -density 300 -trim TSM_Subsup.pdf -quality 100 TSM_Subsup.jpg
rm Actual_TSM_Subsup.pdf
rm TSM_Subsup.pdf

#Hovmoller TSM (fija)
qpdf enso_evolution-status-fcsts-web.pdf --pages enso_evolution-status-fcsts-web.pdf 15 -- tmp.pdf
pdfcrop --margins '-352 -75 -35 -35' tmp.pdf Hovm.pdf
convert -density 300 -trim Hovm.pdf -quality 100 Hovm.jpg
rm Hovm.pdf

#Viento zonal en Pac. Ecuatorial (fija)
wget -O uv850.gif https://www.cpc.ncep.noaa.gov/products/analysis_monitoring/enso_update/uv850-30d.gif

#Imagen OLR y Anomalía OLR mensual (fija)
wget -O OLR_M1.gif http://www.cpc.ncep.noaa.gov/products/CDB/CDB_Archive_html/bulletin_$mes1$anio1/Tropics/figt25.gif
wget -O OLR_M2.gif http://www.cpc.ncep.noaa.gov/products/CDB/CDB_Archive_html/bulletin_$mes2$anio2/Tropics/figt25.gif
wget -O OLR_M3.gif http://www.cpc.ncep.noaa.gov/products/CDB/CDB_Archive_html/bulletin_$mes3$anio3/Tropics/figt25.gif


#Imagen IOD (fija) NO ESTÁ FUNCIONANDO BIEN
wget --no-cache -U "Mozilla" -O IOD.png http://www.bom.gov.au/climate/enso/monitoring/iod1.png

#Flujos de Plumb  (fija)
python $enlace"calculo_waf.py" --dateinit "$anio1-$mes1-01" --dateend "$anio3-$mes3-$dfm3"
mv psi_plumb_01$mes1$anio1-${dfm3}$mes3$anio3.png Plumb_Trim.png

python $enlace"calculo_waf.py" --dateinit "$anio1-$mes1-01" --dateend "$anio1-$mes1-$dfm1"
mv psi_plumb_01$mes1$anio1-${dfm1}$mes1$anio1.png Plumb_M1.png

python $enlace"calculo_waf.py" --dateinit "$anio2-$mes2-01" --dateend "$anio2-$mes2-$dfm2"
mv psi_plumb_01$mes2$anio2-${dfm2}$mes2$anio2.png Plumb_M2.png

python $enlace"calculo_waf.py" --dateinit "$anio3-$mes3-01" --dateend "$anio3-$mes3-$dfm3"
mv psi_plumb_01$mes3$anio3-${dfm3}$mes3$anio3.png Plumb_M3.png

#Imagen Anomalía Z500 yZ30 trimestral (fija)
python $enlace"anom_var_stereo.py" --dateinit "$anio1-$mes1-01" --dateend "$anio3-$mes3-$dfm3" --variable "Zg" --level "500mb" --latr "-20" --levcont "120" --levint "30" 
mv Anomhgt_500mb_01${mes1}${anio1}_${dfm3}${mes3}${anio3}_-20.jpg zg500_Trim.jpg
python $enlace"anom_var_stereo.py" --dateinit "$anio1-$mes1-01" --dateend "$anio3-$mes3-$dfm3" --variable "Zg" --level "30mb" --latr "-20" --levcont "300" --levint "50"  
mv Anomhgt_30mb_01${mes1}${anio1}_${dfm3}${mes3}${anio3}_-20.jpg zg30_Trim.jpg

#Persistencia Anomalías geopotencial (fija)
wget -O persis_AnomZ500_M3.gif https://www.cpc.ncep.noaa.gov/products/CDB/Extratropics/fige17.gif

#Vórtice polar (fija)
wget -O vorticeHS.gif https://www.cpc.ncep.noaa.gov/products/CDB/Extratropics/figs8.gif

#anomalia mensual pp smn (fija)
wget -O Precip_SMN_M3.gif https://estaticos.smn.gob.ar/hidro/imagenes/allu1m.gif

#anomalia mensual temp smn (fija)
wget -O Temp_SMN_M3.gif https://estaticos.smn.gob.ar/clima/imagenes/atmed1.gif 

#Imagen Anomalía Z500 mensual (fija)
python $enlace"anom_var_stereo.py" --dateinit "$anio1-$mes1-01" --dateend "$anio1-$mes1-$dfm1" --variable "Zg" --level "500mb" --latr "-20" --levcont "120" --levint "30"  
mv Anomhgt_500mb_01${mes1}${anio1}_${dfm1}${mes1}${anio1}_-20.jpg zg500_M1.jpg

python $enlace"anom_var_stereo.py" --dateinit "$anio2-$mes2-01" --dateend "$anio2-$mes2-$dfm2" --variable "Zg" --level "500mb" --latr "-20" --levcont "120" --levint "30" 
mv Anomhgt_500mb_01${mes2}${anio2}_${dfm2}${mes2}${anio2}_-20.jpg zg500_M2.jpg 

python $enlace"anom_var_stereo.py" --dateinit "$anio3-$mes3-01" --dateend "$anio3-$mes3-$dfm3" --variable "Zg" --level "500mb" --latr "-20" --levcont "120" --levint "30"  
mv Anomhgt_500mb_01${mes3}${anio3}_${dfm3}${mes3}${anio3}_-20.jpg zg500_M3.jpg

#Imagen Anomalía Z30 mensual (fija)
python $enlace"anom_var_stereo.py" --dateinit "$anio1-$mes1-01" --dateend "$anio1-$mes1-$dfm1" --variable "Zg" --level "30mb" --latr "-20" --levcont "600" --levint "50"   
mv Anomhgt_30mb_01${mes1}${anio1}_${dfm1}${mes1}${anio1}_-20.jpg zg30_M1.jpg

python $enlace"anom_var_stereo.py" --dateinit "$anio2-$mes2-01" --dateend "$anio2-$mes2-$dfm2" --variable "Zg" --level "30mb" --latr "-20" --levcont "600" --levint "50"  
mv Anomhgt_30mb_01${mes2}${anio2}_${dfm2}${mes2}${anio2}_-20.jpg zg30_M2.jpg 

python $enlace"anom_var_stereo.py" --dateinit "$anio3-$mes3-01" --dateend "$anio3-$mes3-$dfm3" --variable "Zg" --level "30mb" --latr "-20" --levcont "600" --levint "50"   
mv Anomhgt_30mb_01${mes3}${anio3}_${dfm3}${mes3}${anio3}_-20.jpg zg30_M3.jpg

#Imagen Anomalía T30 mensual (fija)
python $enlace"anom_var_stereo.py" --dateinit "$anio1-$mes1-01" --dateend "$anio1-$mes1-$dfm1" --variable "T" --level "30mb" --latr "-20" --levcont "25" --levint "2"   
mv Anomair_30mb_01${mes1}${anio1}_${dfm1}${mes1}${anio1}_-20.jpg T30_M1.jpg

python $enlace"anom_var_stereo.py" --dateinit "$anio2-$mes2-01" --dateend "$anio2-$mes2-$dfm2" --variable "T" --level "30mb" --latr "-20" --levcont "25" --levint "2"  
mv Anomair_30mb_01${mes2}${anio2}_${dfm2}${mes2}${anio2}_-20.jpg T30_M2.jpg 

python $enlace"anom_var_stereo.py" --dateinit "$anio3-$mes3-01" --dateend "$anio3-$mes3-$dfm3" --variable "T" --level "30mb" --latr "-20" --levcont "25" --levint "2"   
mv Anomair_30mb_01${mes3}${anio3}_${dfm3}${mes3}${anio3}_-20.jpg T30_M3.jpg

#anomalia mensual Temp smn (fija)
wget -O Temp_SMN_M3.gif https://estaticos.smn.gob.ar/clima/imagenes/atmed1.gif

#anomalia geop 1000 hPa (fija)
python $enlace"anom_var.py" --dateinit "$anio3-$mes3-01" --dateend "$anio3-$mes3-$dfm3" --variable "Zg" --level "1000mb" --latmin "-80" --latmax "0" --lonmin "0" --lonmax "359" --levcont "90" --levint "20" 
mv Anomhgt_1000mb_01${mes3}${anio3}_${dfm3}${mes3}${anio3}_-80_0_0_359.jpg zg1000_M3.jpg 

#anomalia trimestral smn (fija)
wget -O Precip_SMN_Trim.gif https://estaticos.smn.gob.ar/hidro/imagenes/allu3m.gif

#anomalia trimestral smn (fija)
wget -O Temp_SMN_Trim.gif https://estaticos.smn.gob.ar/clima/imagenes/atmed3.gif

#anomalia mensual SSA (fija)
wget --no-check-certificate -O Temp_SSA_M3.gif https://www.crc-sas.org/es/clima/imagenes/Ratmed1.gif

#anomalia trimestral SSA (fija)
wget --no-check-certificate -O Temp_SSA_Trim.gif https://www.crc-sas.org/es/clima/imagenes/Ratmed3.gif

#Monitoreo Agujero Ozono (Fija)
wget -O Ozono_CPC.png http://www.cpc.ncep.noaa.gov/products/stratosphere/polar/gif_files/ozone_hole_plot.png
wget -O Ozono_Copernicus.png https://sites.ecmwf.int/data/cams/plots/ozone/cams_sh_ozone_area_$anio.png
wget -O TempMinAnt_Copernicus.png https://sites.ecmwf.int/data/cams/plots/ozone/cams_sh_50hPa_temperature_minimum_$anio.png

#Monitoreo Agujero Ozono (¡¡¡Cambiar!!!)
wget -O Ozono_sounding.png https://www.esrl.noaa.gov/gmd/webdata/ozwv/ozsNDJes/spo/iadv/SPO_$anio-15-11.21.png

#Monitoreo Estratósfera (Fija)
wget -O AnomT_SH_tvsp_2002.png https://www.cpc.ncep.noaa.gov/products/stratosphere/strat-trop/gif_files/time_pres_TEMP_ANOM_ALL_SH_2002.gif
wget -O AnomU_SH_tvsp_2002.png https://www.cpc.ncep.noaa.gov/products/stratosphere/strat-trop/gif_files/time_pres_UGRD_ANOM_ALL_SH_2002.gif
wget -O AnomT_SH_tvsp.png https://www.cpc.ncep.noaa.gov/products/stratosphere/strat-trop/gif_files/time_pres_TEMP_ANOM_ALL_SH_$anio.png
wget -O AnomU_SH_tvsp.png https://www.cpc.ncep.noaa.gov/products/stratosphere/strat-trop/gif_files/time_pres_UGRD_ANOM_ALL_SH_$anio.png

#Monitoreo Estratósfera (Fija)
wget -O vt_4575.pdf https://acd-ext.gsfc.nasa.gov/Data_services/met/metdata/annual/merra2/flux/vt45_75-45s_50_${anio}_merra2.pdf
convert -density 300 -trim vt_4575.pdf -quality 100 vt_4575.jpg

wget -O u_60.pdf https://acd-ext.gsfc.nasa.gov/Data_services/met/metdata/annual/merra2/wind/u60s_10_${anio}_merra2.pdf
convert -density 300 -trim u_60.pdf -quality 100 u_60.jpg

#Imagen MEI (fija)
wget -O MEI.png https://www.esrl.noaa.gov/psd/enso/mei/img/mei_lifecycle_current.png

#Imagen Prono ENSO (fija)
wget -O PronoENSO_Anterior.png https://iri.columbia.edu/wp-content/uploads/$anio3/$mes3/figure1.png
wget -O PronoENSO.png https://iri.columbia.edu/wp-content/uploads/$anio/$cumes/figure1.png

#Imagen Pluma ENSO (Mes actual puede no estar según en qué fecha se haga la presentación)
wget -O Pluma_PronoENSO_MesActual.png https://iri.columbia.edu/wp-content/uploads/$anio3/$cumes/figure4.png
wget -O Pluma_PronoENSO_MesAnterior.png https://iri.columbia.edu/wp-content/uploads/$anio3/$mes3/figure4.png

#Imagen Prono IOD (fija)
wget --no-cache -U "Mozilla" -O PronoIOD.png http://www.bom.gov.au/climate/enso/wrap-up/archive/${anio}${cumes}${martes}.sstOutlooks_iod.png
wget --no-cache -U "Mozilla" -O PronoIOD_NextMon.png http://www.bom.gov.au/climate/model-summary/archive/${anio}${cumes}${martes}.iod_summary_2.png
wget --no-cache -U "Mozilla" -O PronoIOD_NextOtMon.png http://www.bom.gov.au/climate/model-summary/archive/${anio}${cumes}${martes}.iod_summary_3.png

#Imagen Prono Precip NMME (¡¡¡Cambiar!!!)
wget -O Prono_Precip_NMME.png http://www.cpc.ncep.noaa.gov/products/international/nmme/probabilistic_seasonal/samerica_nmme_prec_3catprb_NovIC_Dec2021-Feb2022.png

#Imagen Prono Temp NMME (¡¡¡Cambiar!!!)
wget -O Prono_Temp_NMME.png http://www.cpc.ncep.noaa.gov/products/international/nmme/probabilistic_seasonal/samerica_nmme_tmp2m_3catprb_NovIC_Dec2021-Feb2022.png

#Imagen Prono Precip IRI (¡¡¡Cambiar!!!)
wget -O Prono_Precip_IRI.gif https://iri.columbia.edu/climate/forecast/net_asmt_nmme/$anio/nov${anio}/images/DJF22_SAm_pcp.gif
 
#Imagen Prono Temp IRI (¡¡¡Cambiar!!!)
wget -O Prono_Temp_IRI.gif https://iri.columbia.edu/climate/forecast/net_asmt_nmme/$anio/nov${anio}/images/DJF22_SAm_tmp.gif

#Imagen Prono DIVAR (¡¡¡Cambiar!!!)
wget -O Prono_Precip_DIVAR.png http://climar.cima.fcen.uba.ar/grafEstacional/for_prec_DJF_ic_Nov_${anio}_wsereg_mean_cor.png
 
#Imagen Prono DIVAR (¡¡¡Cambiar!!!)
wget -O Prono_Temp_DIVAR.png http://climar.cima.fcen.uba.ar/grafEstacional/for_tref_DJF_ic_Nov_${anio}_wsereg_mean_cor.png

#prono copernicus (Cambiar)
wget --no-cache -O Prono_Temp_copernicus.png https://stream.ecmwf.int/data/gorax-blue-009/data/scratch/20210920-0800/d4/convert_image-gorax-blue-009-6fe5cac1a363ec1525f54343b6cc9fd8-bYugvF.png

#prono copernicus (Cambiar)
wget --no-cache -O Prono_Precip_copernicus.png https://stream.ecmwf.int/data/gorax-blue-009/data/scratch/20210919-1940/63/convert_image-gorax-blue-009-6fe5cac1a363ec1525f54343b6cc9fd8-jLxoc4.png 

rm tmp.pdf enso_evolution-status-fcsts-web.pdf


