#!/bin/csh -f

if ( $?config_modeldata ) exit 0
set config_modeldata = 1

source config/workflow.csh
source config/model.csh
source config/forecast.csh
source config/variational.csh
source config/filestructure.csh
set wd = `pwd`
source config/tools.csh $wd
source config/mpas/${MPASGridDescriptor}/mesh.csh
source config/${InitializationType}ModelData.csh

## file date for first background
set yy = `echo ${FirstCycleDate} | cut -c 1-4`
set mm = `echo ${FirstCycleDate} | cut -c 5-6`
set dd = `echo ${FirstCycleDate} | cut -c 7-8`
set hh = `echo ${FirstCycleDate} | cut -c 9-10`
setenv FirstFileDate ${yy}-${mm}-${dd}_${hh}.00.00

## next date from which first background is initialized
set nextFirstCycleDate = `$advanceCYMDH ${FirstCycleDate} +${CyclingWindowHR}`
setenv nextFirstCycleDate ${nextFirstCycleDate}
set Nyy = `echo ${nextFirstCycleDate} | cut -c 1-4`
set Nmm = `echo ${nextFirstCycleDate} | cut -c 5-6`
set Ndd = `echo ${nextFirstCycleDate} | cut -c 7-8`
set Nhh = `echo ${nextFirstCycleDate} | cut -c 9-10`
set nextFirstFileDate = ${Nyy}-${Nmm}-${Ndd}_${Nhh}.00.00

## RDA data on Cheyenne
setenv RDAdataDir /gpfs/fs1/collections/rda/data

## RDA GFS forecasts
setenv GFSgribdirRDA ${RDAdataDir}/ds084.1

## linkWPS and Vtable files paths
setenv VtableDir /glade/u/home/schwartz/MPAS_scripts

# externally sourced model states
# -------------------------------
## deterministic - GFS
setenv GFS6hfcFORFirstCycleOuter ${OuterModelData}/SingleFCFirstCycle/${FirstCycleDate}
setenv GFS6hfcFORFirstCycleInner ${InnerModelData}/SingleFCFirstCycle/${FirstCycleDate}

# first cycle background state
setenv firstDetermFCDirOuter ${GFS6hfcFORFirstCycleOuter}
setenv firstDetermFCDirInner ${GFS6hfcFORFirstCycleInner}

## stochastic - GEFS
set gefsMemPrefix = "None"
set gefsMemNDigits = 2
set gefsMemFmt = "/{:0${gefsMemNDigits}d}"
set nGEFSMembers = 20
set GEFS6hfcFOREnsBDir = ${EnsembleModelData}/EnsForCov
set GEFS6hfcFOREnsBFilePrefix = EnsForCov
set GEFS6hfcFORFirstCycle = ${EnsembleModelData}/EnsFCFirstCycle/${FirstCycleDate}

# first cycle background states
# TODO: determine firstEnsFCNMembers from source data
setenv firstEnsFCNMembers 80
setenv firstEnsFCDir ${GEFS6hfcFORFirstCycle}
if ( $nEnsDAMembers > $firstEnsFCNMembers ) then
  echo "WARNING: nEnsDAMembers must be <= firstEnsFCNMembers, changing ensemble size"
  setenv nEnsDAMembers ${firstEnsFCNMembers}
endif


if ( "$DAType" =~ *"eda"* ) then
  setenv firstFCMemFmt "${gefsMemFmt}"
  setenv firstFCDirOuter ${firstEnsFCDir}
  setenv firstFCDirInner ${firstEnsFCDir}
  setenv firstFCFilePrefix ${FCFilePrefix}
else
  setenv firstFCMemFmt " "
  setenv firstFCDirOuter ${firstDetermFCDirOuter}
  setenv firstFCDirInner ${firstDetermFCDirInner}
  setenv firstFCFilePrefix ${FCFilePrefix}
endif

# background covariance
# ---------------------
## stochastic analysis (dynamic directory structure, depends on $nEnsDAMembers)
set dynamicEnsBMemPrefix = "${flowMemPrefix}"
set dynamicEnsBMemNDigits = ${flowMemNDigits}
set dynamicEnsBFilePrefix = ${FCFilePrefix}

## select the ensPb settings based on DAType
if ( "$DAType" =~ *"eda"* ) then
  set dynamicEnsBNMembers = ${nEnsDAMembers}
  set dynamicEnsBDir = ${CyclingFCWorkDir}

  setenv ensPbDir ${dynamicEnsBDir}
  setenv ensPbFilePrefix ${dynamicEnsBFilePrefix}
  setenv ensPbMemPrefix ${dynamicEnsBMemPrefix}
  setenv ensPbMemNDigits ${dynamicEnsBMemNDigits}
  setenv ensPbNMembers ${dynamicEnsBNMembers}
else
  ## deterministic analysis (static directory structure)
  # parse selections
  if ("$fixedEnsBType" == "GEFS") then
    set fixedEnsBMemPrefix = "${gefsMemPrefix}"
    set fixedEnsBMemNDigits = ${gefsMemNDigits}
    set fixedEnsBNMembers = ${nGEFSMembers}
    set fixedEnsBDir = ${GEFS6hfcFOREnsBDir}
    set fixedEnsBFilePrefix = ${GEFS6hfcFOREnsBFilePrefix}
  else if ("$fixedEnsBType" == "PreviousEDA") then
    set fixedEnsBMemPrefix = "${dynamicEnsBMemPrefix}"
    set fixedEnsBMemNDigits = ${dynamicEnsBMemNDigits}
    set fixedEnsBNMembers = ${nPreviousEnsDAMembers}
    set fixedEnsBDir = ${PreviousEDAForecastDir}
    set fixedEnsBFilePrefix = ${dynamicEnsBFilePrefix}
  else
    echo "ERROR in $0 : unrecognized value for fixedEnsBType --> ${fixedEnsBType}" >> ./FAIL
    exit 1
  endif

  setenv ensPbDir ${fixedEnsBDir}
  setenv ensPbFilePrefix ${fixedEnsBFilePrefix}
  setenv ensPbMemPrefix "${fixedEnsBMemPrefix}"
  setenv ensPbMemNDigits "${fixedEnsBMemNDigits}"
  setenv ensPbNMembers ${fixedEnsBNMembers}
endif


# MPAS-Model
# ----------
## sea/ocean surface files
setenv seaMaxMembers ${nGEFSMembers}
setenv deterministicSeaAnaDir ${GFSAnaDirOuter}
if ( "$DAType" =~ *"eda"* ) then
  # using member-specific sst/xice data from GEFS
  # 60km and 120km
  setenv SeaAnaDir ${ModelData}/GEFS/surface/000hr/${forecast__precision}
  setenv seaMemFmt "${gefsMemFmt}"
else
  # deterministic
  # 60km and 120km
  setenv SeaAnaDir ${deterministicSeaAnaDir}
  setenv seaMemFmt " "
endif

## static stream data
if ( "$DAType" =~ *"eda"* ) then
  # stochastic
  # 60km and 120km
  setenv StaticFieldsDirOuter ${ModelData}/GEFS/init/000hr/${FirstCycleDate}
  setenv StaticFieldsDirInner ${ModelData}/GEFS/init/000hr/${FirstCycleDate}
  setenv StaticFieldsDirEnsemble ${ModelData}/GEFS/init/000hr/${FirstCycleDate}
  setenv staticMemFmt "${gefsMemFmt}"

  #TODO: switch to using FirstFileDate static files for GEFS
  setenv StaticFieldsFileOuter ${InitFilePrefixOuter}.${FirstFileDate}.nc
  setenv StaticFieldsFileInner ${InitFilePrefixInner}.${FirstFileDate}.nc
  setenv StaticFieldsFileEnsemble ${InitFilePrefixEnsemble}.${FirstFileDate}.nc
else
  # deterministic
  # 30km, 60km, and 120km
  setenv StaticFieldsDirEnsemble ${GFSAnaDirEnsemble}
  setenv staticMemFmt " "
  setenv StaticFieldsFileOuter ${InitFilePrefixOuter}.${FirstFileDate}.nc
  setenv StaticFieldsFileInner ${InitFilePrefixInner}.${FirstFileDate}.nc
  setenv StaticFieldsFileEnsemble ${InitFilePrefixEnsemble}.${FirstFileDate}.nc
endif
