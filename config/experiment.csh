#!/bin/csh -f

source config/appindex.csh
source config/obs.csh

##################################
## Fundamental experiment settings
##################################
## MPASGridDescriptor
# used to distinguish betwen MPAS meshes across experiments
# O = variational Outer loop, forecast, HofX
# I = variational Inner loop
# E = variational Ensemble
# OPTIONS:
#   + OIE120km 3denvar
#   + OIE120km eda_3denvar
#   + TODO: "OIE30km" 3denvar
#   + TODO: "O30kmIE120km" dual-resolution 3denvar
#   + TODO: "O30kmIE120km" dual-resolution eda_3denvar
#   + TODO: "OIE120km" 4denvar
#   + TODO: "O30kmIE120km" dual-resolution 4denvar
setenv MPASGridDescriptor OIE120km

## FirstCycleDate
# initial date of this experiment
# OPTIONS:
#   + 2018041500
#   + 2020072300 --> experimental
#     - TODO: standardize GFS and observation source data
#     - TODO: enable QC
#     - TODO: enable VarBC
setenv FirstCycleDate 2018041500

## ExpSuffix
# a unique suffix to distinguish this experiment from others
set ExpSuffix = '_feature--obserrorTuning'

##############
## DA settings
##############

## DAType
# OPTIONS: 3denvar, eda_3denvar, 3dvarId
setenv DAType 3denvar

if ( "$DAType" =~ *"eda"* ) then
  ## nEnsDAMembers
  # OPTIONS: 2 to $firstEnsFCNMembers, depends on data source in config/modeldata.csh
  setenv nEnsDAMembers 20
else
  setenv nEnsDAMembers 1

  ## fixedEnsBType
  # selection of data source for fixed ensemble background covariance members
  # OPTIONS: GEFS (default), PreviousEDA
  set fixedEnsBType = GEFS

  # tertiary settings for when fixedEnsBType is set to PreviousEDA
  set nPreviousEnsDAMembers = 20
  set PreviousEDAForecastDir = \
    /glade/scratch/guerrett/pandac/guerrett_eda_3denvar_NMEM${nPreviousEnsDAMembers}_LeaveOneOut_OIE120km/CyclingFC
endif

## LeaveOneOutEDA
# OPTIONS: True/False
setenv LeaveOneOutEDA True

## RTPPInflationFactor
# Typical Values: 0.0 or 0.50 to 0.90
setenv RTPPInflationFactor 0.0

## ABEIInflation
# OPTIONS: True/False
setenv ABEInflation False

## ABEIChannel
# OPTIONS: 8, 9, 10
setenv ABEIChannel 8

## GeometryInterpolationType
# controls the horizontal interpolation between States/Increments in variational applications
# OPTIONS: bump, unstructured (recommended)
setenv GeometryInterpolationType unstructured

#GEFS reference case (override above settings)
#====================================================
#set ExpSuffix = _GEFSVerify
#setenv DAType eda_3denvar
#setenv nEnsDAMembers 20
#setenv RTPPInflationFactor 0.0
#setenv LeaveOneOutEDA False
#set variationalObsList = ($benchmarkObsList)
#====================================================

##################################
## analysis and forecast intervals
##################################
setenv CyclingWindowHR 6                # forecast interval between CyclingDA analyses
setenv ExtendedFCWindowHR 240           # length of verification forecasts
setenv ExtendedFC_DT_HR 12              # interval between OMF verification times of an individual forecast
setenv ExtendedMeanFCTimes T00,T12      # times of the day to run extended forecast from mean analysis
setenv ExtendedEnsFCTimes T00           # times of the day to run ensemble of extended forecasts
setenv DAVFWindowHR ${CyclingWindowHR}  # window of observations included in AN/BG verification
setenv FCVFWindowHR 6                   # window of observations included in forecast verification
