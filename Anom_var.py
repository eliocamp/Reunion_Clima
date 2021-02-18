#This script takes a initial date and final date and downloads the files needed 
#to compute the anomaly of the variable/level specified
#for that given period. NCEP/NCAR Reanalysis (Kalnay etal 1996)are used 

# As an example to run by shell: python Anom_var.py --dateinit "2018-02-01" --dateend "2018-02-28" --variable "Zg" --level "200mb" --latmin "-60" --latmax "-20" --lonmin "250" --lonmax "340" --levcont "200" --levint "20"

#libraries needed
import urllib.request
from bs4 import BeautifulSoup
import netCDF4
import argparse 
import datetime
from matplotlib import pyplot as plt
import cartopy.crs as ccrs	
import numpy as np 
import cartopy.feature 	
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter


def clean():   #clean enviroment
    import os
    os.system("rm -f ./tmp/*.gz ./tmp/*.nc")

def descarga_nc(inid, inim, find, finm, finy, var_desc,var, level):
    # Open NCEP NCAR access to link to data
    url = 'http://www.psl.noaa.gov/cgi-bin/data/composites/comp.day.pl?var='+var_desc+'&level='+level+'&iy[1]=&im[1]=&id[1]=&iy[2]=&im[2]=&id[2]=&iy[3]=&im[3]=&id[3]=&iy[4]=&im[4]=&id[4]=&iy[5]=&im[5]=&id[5]=&iy[6]=&im[6]=&id[6]=&iy[7]=&im[7]=&id[7]=&iy[8]=&im[8]=&id[8]=&iy[9]=&im[9]=&id[9]=&iy[10]=&im[10]=&id[10]=&iy[11]=&im[11]=&id[11]=&iy[12]=&im[12]=&id[12]=&iy[13]=&im[13]=&id[13]=&iy[14]=&im[14]=&id[14]=&iy[15]=&im[15]=&id[15]=&iy[16]=&im[16]=&id[16]=&iy[17]=&im[17]=&id[17]=&iy[18]=&im[18]=&id[18]=&iy[19]=&im[19]=&id[19]=&iy[20]=&im[20]=&id[20]&monr1='+str(inim)+'&dayr1='+str(inid)+'&monr2='+str(finm)+'&dayr2='+str(find)+'&iyr[1]='+str(finy)+'&filenamein=&plotlabel=&lag=0&labelc=Color&labels=Shaded&type=2&scale=&label=0&cint=&lowr=&highr=&istate=0&proj=ALL&xlat1=&xlat2=&xlon1=&xlon2=&custproj=Cylindrical+Equidistant&level1=1000mb&level2=10mb&Submit=Create+Plot'
    response = urllib.request.urlopen(url)
    data = response.read()      # a `bytes` object
    soup = BeautifulSoup(data,'html.parser') #is an xml, beautifull has a module to manage it
	#A very inefficient way to get the nc file
    link = soup.findAll('img')[-1]['src'] 
    link=list(link)
    link[-3]='n'
    link[-2]='c'
    link[-1]=''     
    #get nc file save as netcdf
    ruta = "./tmp/"
    url_nc='http://www.psl.noaa.gov'+"".join(link)
    urllib.request.urlretrieve(url_nc, ruta+var+'.nc')

def manipular_nc(archivo,variable):

    dataset = netCDF4.Dataset(archivo, 'r')
    var_out = dataset.variables[variable][:]
    lat = dataset.variables['lat'][:]
    lon = dataset.variables['lon'][:]
    dataset.close()
    return var_out, lat, lon

def main():
  
	# Define parser data
    parser = argparse.ArgumentParser(description='Plotting Anomalies for given dates, variable')
    # First arguments. Initial Date Format yyyy-mm-dd
    parser.add_argument('--dateinit',dest='date_init', metavar='Date', type=str,
                        nargs=1,help='Initial date in "YYYY-MM-DD"')    
    #Second argument: Final Date Format yyyy-mm-dd
    parser.add_argument('--dateend',dest='date_end', metavar='Date', type=str,
                        nargs=1,help='Final date in "YYYY-MM-DD"')
    #Thrid argument: Variable U (zonal wind), V (meridional wind) or Zg (geopotential height)
    parser.add_argument('--variable',dest='VAR', metavar='var', type=str,
                        nargs=1,help='Variable Name U,V or Zg"')
    #Fourth argument: level of the variable in hPa or mb
    parser.add_argument('--level',dest='LEVEL', metavar='lev', type=str,
                        nargs=1,help='Level in hPa with units included (mb)')
    #Fifth argument: Minimum Latitude for the graph range
    parser.add_argument('--latmin',dest='LATI', metavar='lati', type=str,
                        nargs=1,help='Minimum latitude')
    #Sixth argument: Maximum Latitude for the graph range
    parser.add_argument('--latmax',dest='LATF', metavar='latf', type=str,
                        nargs=1,help='Maximum latitude')
    #Seventh argument: Minimum Longitude for the graph range
    parser.add_argument('--lonmin',dest='LONI', metavar='loni', type=str,
                        nargs=1,help='Minimum longitude')
    #Eighth argument: Maximum Longitude for the graph range
    parser.add_argument('--lonmax',dest='LONF', metavar='lonf', type=str,
                        nargs=1,help='Maximum longitude')
    #Ninth argument: Maximum level for contour
    parser.add_argument('--levcont',dest='LEVCONT', metavar='levcont', type=str,
                        nargs=1,help='Maximum level for contour')
    #Tenth argument: Interval level for contour
    parser.add_argument('--levint',dest='LEVINT', metavar='levint', type=str,
                        nargs=1,help='Interval level for contour')

    # Extract dates from args
    args=parser.parse_args()

    initialDate = datetime.datetime.strptime(args.date_init[0], '%Y-%m-%d')
    finalDate = datetime.datetime.strptime(args.date_end[0], '%Y-%m-%d')

    var=args.VAR[0]
    level=args.LEVEL[0]
    lati=args.LATI[0]
    latf=args.LATF[0]
    loni=args.LONI[0]
    lonf=args.LONF[0]
    levcont=args.LEVCONT[0]
    levint=args.LEVINT[0]
 
    clean()

    #initial date
    iniy = initialDate.year    
    inim = initialDate.month
    inid = initialDate.day
    
    #final date
    finy = finalDate.year
    finm = finalDate.month
    find = finalDate.day

    #download file with variable

    if (var=='U'):
        var_desc='Zonal+Wind'
        var='uwnd'
    elif (var=='V'):
        var_desc='Meridional+Wind'        
        var='vwnd'
    elif (var=='Zg'):
        var_desc='Geopotential+Height'        
        var='hgt'
    else:
        print('ERROR: Wrong Variable')
        
    descarga_nc(inid, inim, find, finm, finy, var_desc,var, level)

    ruta = "./tmp/"
    [anomvar,lat,lon] = manipular_nc(ruta+var+'.nc',var)

    fig = plt.figure(figsize=(16, 11)) 
    
    ax = plt.subplot(projection=ccrs.PlateCarree(central_longitude=180))

    #Pasamos las latitudes/longitudes del dataset a una reticula para graficar
    lons, lats = np.meshgrid(lon,lat)
    clevs = np.arange(-int(levcont),int(levcont)+int(levint),int(levint))
    crs_latlon = ccrs.PlateCarree()
    ax.set_extent([int(loni),int(lonf), int(lati), int(latf)], crs=crs_latlon)
    im=ax.contourf(lons, lats, np.squeeze(anomvar),clevs,transform=crs_latlon,cmap='RdBu_r',extend='both')
    ax.contour(lons, lats, np.squeeze(anomvar),clevs,colors='k',transform=crs_latlon)
    #plt.colorbar(im,fraction=0.02, pad=0.04,shrink=0.8,aspect=12)
    cbar = plt.colorbar(im, fraction=0.052, pad=0.04,shrink=0.3,aspect=12)#,"right")
    ax.add_feature(cartopy.feature.COASTLINE)
    ax.add_feature(cartopy.feature.BORDERS, linestyle='-', alpha=.5)
    ax.gridlines(crs=crs_latlon, linewidth=0.3, linestyle='-')
    ax.set_xticks(np.linspace(0, 360,  7), crs=crs_latlon)
    ax.set_yticks(np.linspace(-80, 10,  10), crs=crs_latlon)    
    lon_formatter = LongitudeFormatter(zero_direction_label=True)
    lat_formatter = LatitudeFormatter()
    ax.xaxis.set_major_formatter(lon_formatter)
    ax.yaxis.set_major_formatter(lat_formatter)
    ax.set_title('Anomalías '+var+' '+level+' '+str(inid)+'/'+str(inim)+'/'+str(iniy)+'-'+str(find)+'/'+str(finm)+'/'+str(finy))
    #Save in jpg

    plt.savefig('Anom'+var+'_'+level+'_'+'{:02d}'.format(inid)+'{:02d}'.format(inim)+str(iniy)+'_'+'{:02d}'.format(find)+'{:02d}'.format(finm)+str(finy)+'_'+str(lati)+'_'+str(latf)+'_'+str(loni)+'_'+str(lonf)+'.jpg',dpi=300,bbox_inches='tight',orientation='landscape')

#begin        
if __name__ == "__main__":
    main() 
