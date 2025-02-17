#!/bin/csh -f

if ( $?config_environmentForJedi ) exit 0
setenv config_environmentForJedi 1

# Process arguments
# =================
## args
# BuildCompiler: combination of compiler and MPI implementation used to build JEDI
#                (defined in config/builds.csh)
# OPTIONS: gnu-openmpi, intel-impi

set BuildCompiler = "$1"

source /etc/profile.d/modules.csh
setenv OPT /glade/work/jedipara/cheyenne/opt/modules
module purge
module use $OPT/modulefiles/core
module load jedi/$BuildCompiler
module load json
module load json-schema-validator
limit stacksize unlimited
setenv OOPS_TRACE 0
setenv OOPS_DEBUG 0
#setenv OOPS_TRAPFPE 1
module list
setenv GFORTRAN_CONVERT_UNIT 'big_endian:101-200'
setenv F_UFMTENDIAN 'big:101-200'
setenv OMP_NUM_THREADS 1

## CustomPIO
# whether to unload the JEDI module PIO module
# A custom PIO build (outside JEDI modules) must be used consistently across all MPAS-JEDI and
# MPAS-Model executable builds
set CustomPIO = False
if ( CustomPIO == True ) then
  module unload pio
endif
