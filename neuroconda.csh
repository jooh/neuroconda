#!/bin/csh -e
# shell script wrapper for Neuroconda at MRC CBU, University of Cambridge. This script
# takes care of adding non-conda packages to the system path before activating the
# environment. This helps ensure that non-conda packages are pinned to specific versions
# for reproducibility.
#
# Usage: source neuroconda.csh in your login shell session.

setenv NEUROCONDA_OLDPATH "$PATH"
if ( ! $?MATLABPATH ) then
    setenv MATLABPATH ""
endif
setenv NEUROCONDA_OLDMATLABPATH "$MATLABPATH"
if ( ! $?FREESURFER_HOME ) then
    setenv FREESURFER_HOME ""
endif
setenv NEUROCONDA_OLDFREESURFER_HOME "$FREESURFER_HOME"
setenv NEUROCONDA_TEST "HELLO"

# matlab
setenv PATH "/hpc-software/matlab/r2019a/bin:$PATH"
setenv MATLABPATH "/imaging/local/software/spm_cbu_svn/releases/spm12_fil_r7487:$MATLABPATH"

# fsl
setenv FSLDIR "/imaging/local/software/centos7/fsl"
setenv PATH "$FSLDIR/bin:$PATH"
source ${FSLDIR}/etc/fslconf/fsl.csh

# freesurfer
setenv FREESURFER_HOME "/imaging/local/software/freesurfer/6.0.0/x86_64"
source ${FREESURFER_HOME}/SetUpFreeSurfer.csh

# afni
setenv PATH "/imaging/local/software/afni/v18.3.03/:$PATH"

# misc
setenv PATH "/imaging/local/software/centos7/ants/bin/ants/bin:$PATH"

# isolate additions from this script so we can nuke them later
setenv NEUROCONDA_NEWPATH `echo "$PATH" | sed 's@'"$NEUROCONDA_OLDPATH"'@@g'`

# work out script directory
# (it's instructive to compare how ugly and slow this is compared to the bash solution)
set scriptdir = `lsof -w +p $$ | grep -oE /.\*neuroconda.csh | xargs -0 dirname`
# work out what the conda version is
setenv NEUROCONDA_VERSION `cat $scriptdir/neuroconda.yml | tr -s ' ' | grep -o 'name: .*' | cut -d ' ' -f 2`

conda activate "$NEUROCONDA_VERSION"
echo Welcome to "$NEUROCONDA_VERSION", running at "$CONDA_PREFIX"
