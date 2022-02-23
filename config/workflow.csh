#!/bin/csh -f

if ( $?config_workflow ) exit 0
setenv config_workflow 1

source config/scenario.csh

# getWorkflow and setWorkflow are helper functions that pick out individual
# configuration elements from within the "workflow" key of the scenario configuration
setenv getWorkflow "$getConfig $baseConfig $scenarioConfig workflow"
setenv setWorkflow "source $setConfig $baseConfig $scenarioConfig workflow"

$setWorkflow firstCyclePoint

## Set the FirstCycleDate in the right format for non-cylc parts of the workflow
set yymmdd = `echo ${firstCyclePoint} | cut -c 1-8`
set hh = `echo ${firstCyclePoint} | cut -c 10-11`
setenv FirstCycleDate ${yymmdd}${hh}

$setWorkflow initialCyclePoint
$setWorkflow finalCyclePoint

$setWorkflow InitializationType
$setWorkflow PreprocessObs

$setWorkflow CriticalPathType
$setWorkflow VerifyDeterministicDA
$setWorkflow CompareDA2Benchmark
$setWorkflow VerifyExtendedMeanFC
$setWorkflow VerifyBGMembers
$setWorkflow CompareBG2Benchmark
$setWorkflow VerifyEnsMeanBG
$setWorkflow DiagnoseEnsSpreadBG
$setWorkflow VerifyANMembers
$setWorkflow VerifyExtendedEnsFC
