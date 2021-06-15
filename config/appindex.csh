#!/bin/csh -f

## application indices
#  enables re-use of common components for similar applications

set applicationIndex = ( variational hofx )
set applicationObsIndent = ( 2 0 )

set index = 0
foreach application (${applicationIndex})
  @ index++
  if ( $application == variational ) then
    set variationalIndex = $index
  endif
  if ( $application == hofx ) then
    set hofxIndex = $index
  endif
end
