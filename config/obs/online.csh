#!/bin/csh -f

source config/filestructure.csh
source config/appindex.csh

## InterpolationType
# controls the horizontal interpolation used in variational and hofx applications
# OPTIONS: bump, unstructured
setenv InterpolationType unstructured

#######
# VARBC
#######
setenv INITIAL_VARBC_TABLE /glade/work/guerrett/pandac/fixed_input/satbias/satbias_crtm_in

##########################
# Cycle-dependent Datasets
##########################

## Conventional instruments
setenv ConventionalObsDir ${ObsWorkDir}

set PolarMWObsDir = ()
set PolarMWObsDir[$variationalIndex] = ${ObsWorkDir}
set PolarMWObsDir[$hofxIndex] = ${ObsWorkDir}

set PolarIRObsDir = ()
set PolarIRObsDir[$variationalIndex] = ${ObsWorkDir}
set PolarIRObsDir[$hofxIndex] = ${ObsWorkDir}

#Note: ABI and AHI are not enabled yet.  Below are placeholders only.
set ABIObsDir = ()
set ABIObsDir[$variationalIndex] = ${ObsWorkDir}
set ABIObsDir[$hofxIndex] = ${ObsWorkDir}

set AHIObsDir = ()
set AHIObsDir[$variationalIndex] = ${ObsWorkDir}
set AHIObsDir[$hofxIndex] = ${ObsWorkDir}
