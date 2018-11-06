Conda environment specification for MRC CBU, Cambridge, UK. This is a very inclusive
environment that covers pretty much all neuroimaging-related packages you might want to
use. Please let us know if you want to see any additional packages.

The idea with this repo is to provide an open specification of the environment that was
used to run a particular analysis on the CBU imaging system. 

# Usage (on the CBU imaging system)


TCSH / CSH shells (CBU standard - put this in your ~/.cshrc file to get this environment in
every new shell):

```
source /imaging/local/software/centos7/anaconda3/etc/profile.d/conda.csh
conda activate cbu_nipy_201811
```

BASH (it's better - put this in your ~/.bashrc file to get this environment in every new
shell):
```
. /imaging/local/software/centos7/anaconda3/etc/profile.d/conda.sh
conda activate cbu_nipy_201811
```

# Installing

This environment is already available on the CBU imaging system, currently under
/imaging/local/software/centos7/anaconda3. You shouldn't have to install it yourself
(and if you do you may need to change the prefix setting).

If you are installing elsewhere, it's a simple matter of

```
conda env create -f cbu_nipy_env.yaml
```
You will then have to locate the directory for your environment (typically through
`source activate [envname]; echo $CONDA_PREFIX`), and copy over the environment
variables (assuming you are in the repo root):

```
rsync -av --exclude '*.swp' etc/ "$CONDA_PREFIX"/etc/
```

The last bit is optional - if you already have the packages you want to use on your path
(e.g. through adding them in your shell login script) you don't need to add them again.
This functionality is mainly useful for the CBU imaging setup, where nothing is on the
path by default (and we want to be able to increment the versions of these dependencies
together with the conda environment releases).

# Dependencies
We add the following packages to the PATH while activating the environment. You would
need to install these packages yourself to mirror our setup (and change the install
locations in [/etc/conda/activate.d/env_vars.sh](env_vars.sh) to match):

* SPM 12 / Matlab r2018a
* ANTS
* Freesurfer
* FSL

# Problems
Please contact Johan Carlin or open an issue.
