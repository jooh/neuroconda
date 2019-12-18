#!/bin/bash -e
# currently broken, awaiting fixes for
# https://github.com/MRC-CBU/neuroconda/issues/1
# https://github.com/conda/conda/issues/3915

# filter out anything we added to path during activation
export PATH=`echo "$PATH" | sed 's@'"$NEUROCONDA_NEWPATH"'@@g'`
export MATLABPATH="$NEUROCONDA_OLDMATLABPATH"
export FREESURFER_HOME="$NEUROCONDA_OLDFREESURFER_HOME"
export NEUROCONDA_TEST="GOODBYE"
