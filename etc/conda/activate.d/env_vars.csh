#!/bin/csh -f

# matlab
setenv PATH "/hpc-software/matlab/r2018a/bin:$PATH"
if ( ! $?MATLABPATH ) then
    setenv MATLABPATH ""
endif
setenv MATLABPATH "/imaging/local/software/spm_cbu_svn/releases/spm12_fil_r7219:$MATLABPATH"

# fsl
setenv FSLDIR "/imaging/local/software/centos7/fsl"
setenv PATH "$FSLDIR/bin:$PATH"
source ${FSLDIR}/etc/fslconf/fsl.csh

# freesurfer
setenv FREESURFER_HOME "/imaging/local/software/freesurfer/6.0.0/x86_64"
source ${FREESURFER_HOME}/SetUpFreeSurfer.csh

# misc
setenv PATH "/imaging/local/software/dcm2niix/bin:$PATH"
setenv PATH "/imaging/local/software/centos7/ants/bin/ants/bin:$PATH"

setenv CBU_NIPY_VERSION 201811_csh
