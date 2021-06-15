#!/bin/csh -f

source config/appindex.csh

## ObsInterpolationType
# controls the horizontal interpolation for observations used in both variational and
# hofx applications
# OPTIONS: bump, unstructured
setenv ObsInterpolationType unstructured

## Conventional instrument list
set conventionalObsList = (aircraft gnssro satwind sfc sondes)

## benchmarkObsList
# base set of observation types assimilated in all experiments
set benchmarkObsList = (${conventionalObsList} clramsua)

## ABI super-obbing footprint, set independently
#  for variational and hofx using applicationIndex
#OPTIONS: 15X15, 59X59
set ABISuperOb = (null null)
set ABISuperOb[$variationalIndex] = 59X59
set ABISuperOb[$hofxIndex] = 59X59

## AHI super-obbing footprint set independently
#  for variational and hofx using applicationIndex
#OPTIONS: 15X15, 101X101
set AHISuperOb = (null null)
set AHISuperOb[$variationalIndex] = 101X101
set AHISuperOb[$hofxIndex] = 101X101


#######################
## variational settings
#######################
# add IR super-obbing resolution yaml filename suffixes for variational
# TODO: use sed substitution for differing IR yaml sections instead of unique file naming.
#       Probably solve by adding error tables for individual instruments, including the "ramp"
#       errors, channel selection.  Will eventually have identical ObsPlugs for hofx and
#       variational applications
set allabi = allabi$ABISuperOb[$variationalIndex]
set clrabi = clrabi$ABISuperOb[$variationalIndex]
set allahi = allahi$AHISuperOb[$variationalIndex]
set clrahi = clrahi$AHISuperOb[$variationalIndex]

## variationalObsList
# observation types assimilated in all variational application instances
# must match file names in config/ObsPlugs/variational/*.yaml
# OPTIONS: $benchmarkObsList, cldamsua, $clrabi, $allabi, $clrahi, $allahi
# clr == clear-sky
# cld == cloudy-sky
# all == all-sky
#TODO: separate amsua and mhs config for each instrument_satellite combo

#set variationalObsList = ($benchmarkObsList)
#set variationalObsList = ($benchmarkObsList cldamsua)
#set variationalObsList = ($benchmarkObsList $allabi)
#set variationalObsList = ($benchmarkObsList $allahi)
set variationalObsList = ($benchmarkObsList $allabi $allahi)


################
## hofx settings
################
# add IR super-obbing resolution suffixes for hofx
set allabi = allabi$ABISuperOb[$hofxIndex]
set clrabi = clrabi$ABISuperOb[$hofxIndex]
set allahi = allahi$AHISuperOb[$hofxIndex]
set clrahi = clrahi$AHISuperOb[$hofxIndex]

## hofxObsList
# observation types simulated in all hofx application instances
# must match file names in config/ObsPlugs/hofx/*.yaml
# OPTIONS: $benchmarkObsList, cldamsua, allmhs, $clrabi, $allabi, $clrahi, $allahi
#TODO: separate amsua and mhs config for each instrument_satellite combo
set hofxObsList = ($benchmarkObsList cldamsua allmhs $allabi $allahi)
