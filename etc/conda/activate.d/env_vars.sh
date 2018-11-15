#!/bin/sh

# matlab
export PATH="/hpc-software/matlab/r2018a/bin:$PATH"
export MATLABPATH="/imaging/local/software/spm_cbu_svn/releases/spm12_fil_r7219:$MATLABPATH"

# fsl
export FSLDIR="/imaging/local/software/centos7/fsl"
export PATH="$FSLDIR/bin:$PATH"
source ${FSLDIR}/etc/fslconf/fsl.sh

# freesurfer
export FREESURFER_HOME="/imaging/local/software/freesurfer/6.0.0/x86_64"
source ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# misc
export PATH="/imaging/local/software/centos7/ants/bin/ants/bin/:$PATH"

export CBU_NIPY_VERSION=201811_bash
