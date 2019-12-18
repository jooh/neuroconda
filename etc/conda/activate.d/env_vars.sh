#!/bin/bash -e
# currently broken, awaiting fixes for
# https://github.com/MRC-CBU/neuroconda/issues/1
# https://github.com/conda/conda/issues/3915

export NEUROCONDA_OLDPATH="$PATH"
export NEUROCONDA_OLDMATLABPATH="$MATLABPATH"
export NEUROCONDA_OLDFREESURFER_HOME="$FREESURFER_HOME"
export NEUROCONDA_TEST="HELLO"

# matlab
export PATH="/hpc-software/matlab/r2019a/bin:$PATH"
export MATLABPATH="/imaging/local/software/spm_cbu_svn/releases/spm12_fil_r7487:$MATLABPATH"

# fsl
export FSLDIR="/imaging/local/software/centos7/fsl"
export PATH="$FSLDIR/bin:$PATH"
source ${FSLDIR}/etc/fslconf/fsl.sh

# freesurfer
export FREESURFER_HOME="/imaging/local/software/freesurfer/6.0.0/x86_64"
source ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# misc
export PATH="/imaging/local/software/centos7/ants/bin/ants/bin/:$PATH"

# isolate additions from this script so we can nuke them later
export NEUROCONDA_NEWPATH=`echo "$PATH" | sed 's@'"$NEUROCONDA_OLDPATH"'@@g'`
