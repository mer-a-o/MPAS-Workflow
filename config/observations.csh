#!/bin/csh -f

if ( $?config_observations ) exit 0
setenv config_observations 1

source config/scenario.csh

# setObservations is a helper function that picks out a configuration node
# under the "observations" key of scenarioConfig
setenv baseConfig scenarios/base/observations.yaml
setenv setObservations "source $setConfig $baseConfig $scenarioConfig observations"
setenv setNestedObservations "source $setNestedConfig $baseConfig $scenarioConfig observations"
setenv getObservationsOrNone "source $getConfigOrNone $baseConfig $scenarioConfig observations"

# nested observations__resource
$setNestedObservations resource

$setObservations convertToIODAObservations
$setObservations GDASObsErrtable
$setObservations CRTMTABLES
$setObservations InterpolationType
