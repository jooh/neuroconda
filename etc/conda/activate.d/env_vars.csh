#!/bin/csh

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

# misc
setenv PATH "/imaging/local/software/centos7/ants/bin/ants/bin:$PATH"

setenv PATHALT "$PATH"
