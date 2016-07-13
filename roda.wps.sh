#!/bin/bash +x
DIR_main=/home/junior/wrf/joe_cfsr
DIR_WRF=/home/junior/wrf/joe_cfsr/WRFV3/test/em_real
DIR_WPS=/home/junior/wrf/joe_cfsr/WPS/
DIR_out=/media/Seagate\ Expansion\ Drive/wrf_cfsr
ANO=2015
MES=01
DIA=01

datein=$(date -d "2014-12-31")

skip() {

for i in `seq  1 31`; do

#for d in `seq 1 5 `; do
date0=$(date -d "$datein +$(( ${i} )) days")
date1=$(date -d "$datein +$((1 + ( ${i} ))) days")

date0=`date -d "$date0" +%Y%m%d`
date1=`date -d "$date1" +%Y%m%d`
ano=`date -d "$date0" +%Y`

#echo ${date0}
#echo ${date1}

anos=`date -d "$date0" +%Y`
mess=`date -d "$date0" +%m`
dias=`date -d "$date0" +%d`

datae=`date -d "${date0} 0 days"`
#echo ${datae}

anoe=`date -d "${datae}" +%Y`

mese=`date -d "${datae}" +%m`

diae=`date -d "${datae}" +%d`

#echo final  $anoe $mese $diae

#read

dated=$(date -d "$datae")
#dated=$(date -d "$dated" +%Y%m%d)
dated=`date -d "$datae" +%Y%m%d`

datedd=$(date -d "$dated +$((1)) days")
datedd=`date -d "$datedd" +%Y%m%d`

dateddd=$(date -d "$dated -$((1)) days")
dateddd=`date -d "$dateddd" +%Y%m%d`

echo $dated 'data atual'
echo $datedd 'data posterior'
echo $dateddd 'data anterior'
echo

down(){
#aqui ele abaixa os aqruivos de sst e surface
sleep 1
./get_surface_cfsr_2011_2015.py funceme $dated 0 $ano
mv  cdas1.${dated}.sfluxgrbf.tar surface/
cd surface
rm -fv surface_${dateddd}*
tar -xvf  cdas1.${dated}.sfluxgrbf.tar
#rm -fv cdas1.${dated}.sfluxgrbf.tar
#agora vamos renomear os aquivos que precisamos
mv cdas1.t00z.sfluxgrbf06.grib2 surface_${dated}_06.grib2
mv cdas1.t06z.sfluxgrbf06.grib2 surface_${dated}_12.grib2
mv cdas1.t12z.sfluxgrbf06.grib2 surface_${dated}_18.grib2
mv cdas1.t18z.sfluxgrbf06.grib2 surface_${datedd}_00.grib2
rm -fv cdas1.t*
cd ..

#./get_sst_cfsr_2011_2015.py funceme $dated 0 $ano
#mv cdas1.${dated}.sfluxgrbf.tar sst/
#cd sst
#tar -xvf cdas1.${dated}.sfluxgrbf.tar
#rm -f cdas1.${dated}.sfluxgrbf.tar
#cd ..

./get_pressure_cfsr_2011_2015.py funceme $dated 0 $ano
mv cdas1.${dated}.pgrbh.tar pressure/
cd pressure
rm -fv pressure_${dateddd}*
tar -xvf cdas1.${dated}.pgrbh.tar
#rm -fv cdas1.${dated}.pgrbh.tar
mv cdas1.t00z.pgrbhanl.grib2 pressure_${dated}_00.grib2
mv cdas1.t06z.pgrbhanl.grib2 pressure_${dated}_06.grib2
mv cdas1.t12z.pgrbhanl.grib2 pressure_${dated}_12.grib2
mv cdas1.t18z.pgrbhanl.grib2 pressure_${dated}_18.grib2
rm -f cdas1.t*
cd ..

}
down

#done

cd $DIR_WPS
for vez in pressure sst surface ; do
   if [ $vez == sst  ]; then
           rm -f GRIBFILE*
     ./link_grib.csh ${DIR_main}/surface/surface_*
   elif [ $vez == surface ] ; then
     rm -f GRIBFILE*
                 ./link_grib.csh ${DIR_main}/surface/surface_*
   else
     rm -f GRIBFILE*
     ./link_grib.csh ${DIR_main}/${vez}/${vez}_*
   fi

   rm -f Vtable
   cp ${DIR_main}/Vtable_$vez Vtable
   if [ "${vez}" == "pressure" ]; then
      file=PLEVS  ; fi
   if [ "${vez}" == "sst" ]; then
      file=SST  ; fi
   if [ "${vez}" == "surface" ]; then
      file=SFLUX  ; fi
   sed "s/xfilex/${file}/g" ${DIR_main}/namelist.wps_cat_bh > namelist.wps
   sed -i "s/xanosx/${anos}/g" namelist.wps
   sed -i "s/xmessx/${mess}/g" namelist.wps
   sed -i "s/xdiasx/${dias}/g" namelist.wps
   sed -i "s/xanoex/${anoe}/g" namelist.wps
   sed -i "s/xmesex/${mese}/g" namelist.wps
   sed -i "s/xdiaex/${diae}/g" namelist.wps

./ungrib.exe
done
./metgrid.exe
rm -f FILE*
rm -f GRIBFIL
mv met_em.d* /media/Seagate\ Expansion\ Drive/wrf_cfsr/metfiles/
done # end loop bloco de arquivos CFSR

}
skip

