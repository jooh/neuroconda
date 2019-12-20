#!/bin/bash -e
# shell script wrapper for Neuroconda at MRC CBU, University of Cambridge. This script
# takes care of adding non-conda packages to the system path before activating the
# environment. This helps ensure that non-conda packages are pinned to specific versions
# for reproducibility.
#
# Usage: source neuroconda.sh in your login shell session.

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

# find script directory
scriptdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")
# work out what the conda version is
export NEUROCONDA_VERSION=`cat $scriptdir/neuroconda.yml | tr -s ' ' | grep -o 'name: .*' | cut -d ' ' -f 2`

conda activate "$NEUROCONDA_VERSION"
echo Welcome to "$NEUROCONDA_VERSION", running at "$CONDA_PREFIX"
