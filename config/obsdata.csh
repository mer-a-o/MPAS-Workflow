#!/bin/csh -f

source config/appindex.csh
source config/obs.csh
source config/experiment.csh

##############
# Fixed tables
##############
set FixedInput = /glade/work/guerrett/pandac/fixed_input

## CRTM
setenv CRTMTABLES ${FixedInput}/crtm_bin/

## VARBC
setenv INITIAL_VARBC_TABLE ${FixedInput}/satbias/satbias_crtm_in


##########################
# Cycle-dependent Datasets
##########################

## Conventional instruments
setenv ConventionalObsDir /glade/p/mmm/parc/liuz/pandac_common/ioda_obs_v2/2018/conv_obs

## Polar MW (amsua, mhs)
# bias correction
set PolarMWNoBC = no_bias
set PolarMWGSIBC = bias_corr
setenv PolarMWBiasCorrect $PolarMWGSIBC

# directories
set basePolarMWObsDir = /glade/p/mmm/parc/liuz/pandac_common/ioda_obs_v2/2018
set PolarMWObsDir = ()
foreach application (${applicationIndex})
  set PolarMWObsDir = ($PolarMWObsDir \
    ${basePolarMWObsDir} \
  )
end
set PolarMWObsDir[$variationalIndex] = $PolarMWObsDir[$variationalIndex]/$PolarMWBiasCorrect

# no bias correction for hofx
set PolarMWObsDir[$hofxIndex] = $PolarMWObsDir[$hofxIndex]/$PolarMWNoBC

## Geostationary IR (abi, ahi)
# bias correction suffixes
set GEOIRNoBC = _no-bias-correct
set GEOIRClearBC = _const-bias-correct

# abi directories
set ABITopObsDir = /glade/work/guerrett/pandac/obs/ABIASR/ioda-v2
set baseABIObsDir = ${ABITopObsDir}/IODANC_THIN15KM_SUPEROB
set ABIObsDir = ()
foreach SuperOb ($ABISuperOb)
  set ABIObsDir = ($ABIObsDir \
    ${baseABIObsDir}${SuperOb} \
  )
end

# no bias correction for hofx
set ABIObsDir[$hofxIndex] = $ABIObsDir[$hofxIndex]$GEOIRNoBC


# ahi directories
set AHITopObsDir = /glade/work/guerrett/pandac/obs/AHIASR/ioda-v2
set baseAHIObsDir = ${AHITopObsDir}/IODANC_SUPEROB
#Note: AHI is linked from /glade/work/wuyl/pandac/work/fix_input/AHI_OBS
set AHIObsDir = ()
foreach SuperOb ($AHISuperOb)
  set AHIObsDir = ($AHIObsDir \
    ${baseAHIObsDir}${SuperOb} \
  )
end

# no bias correction for hofx
set AHIObsDir[$hofxIndex] = $AHIObsDir[$hofxIndex]$GEOIRNoBC


# add IR bias correction directory suffixes for variational
setenv ABIBiasCorrect $GEOIRNoBC
setenv AHIBiasCorrect $GEOIRNoBC
foreach obs ($variationalObsList)
  if ( "$obs" =~ "clrabi"* ) then
    setenv ABIBiasCorrect $GEOIRClearBC
  endif
  if ( "$obs" =~ "clrahi"* ) then
    setenv AHIBiasCorrect $GEOIRClearBC
  endif
end
set ABIObsDir[$variationalIndex] = $ABIObsDir[$variationalIndex]$ABIBiasCorrect
set AHIObsDir[$variationalIndex] = $AHIObsDir[$variationalIndex]$AHIBiasCorrect
