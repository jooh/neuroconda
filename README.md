Conda environment specification for MRC CBU, Cambridge, UK. This is a very inclusive
environment that covers pretty much all neuroimaging-related packages you might want to
use. Please let us know if you want to see any additional packages.

The idea with this repo is to provide an open specification of the environment that was
used to run a particular analysis on the CBU imaging system. If you report that you used
a particular release of this environment in your manuscript, you are providing a fairly
complete description of your analysis software.

# Usage (on the CBU imaging system)

If you've never used conda before, you may have to do `conda init`. Then it's on to

```sh
conda activate --stack neuroconda_1_4
```

(Note that it is -not- recommended to put the above line in your login script since this
can cause conflicts with e.g. vncserver.)

## Jupyter Notebook extensions
For first-time users, you may also want to enable the [jupyter notebook
extensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions) with

```sh
jupyter nbextensions_configurator enable --user
```

## Pycortex initial configuration
You will also have problems with pycortex, which looks for file paths in the (invalid) build
directory instead of the final install directory. Work around this by first importing
pycortex to generate the default config, and then editing it to look for the subject database
and colormaps in the correct location (note that if you are using this in a centralised
install at e.g. CBU, you may want the subject database to be somewhere you have write access
instead):

```sh
python -c "import cortex"
sed -i 's@build/bdist.linux-x86_64/wheel/pycortex-1.0.2.data/data@'"$CONDA_PREFIX"'@g' ~/.config/pycortex/options.cfg
```

# Installing

This environment is already available on the CBU imaging system. You shouldn't have to
install it yourself (and if you do you may need to change the prefix setting).

If you are installing elsewhere, it's a simple matter of

```sh
conda env create -f neuroconda.yml --name neuroconda_mine
conda activate --stack neuroconda_mine
```

You may then want to copy over the environment variables (assuming you are in the repo
root and you have activated the environment):

```sh
rsync -av --exclude '*.swp' etc/ "$CONDA_PREFIX"/etc/
```

The last bit is optional - if you already have the packages you want to use on your path
(e.g. through adding them in your shell login script) you don't need to add them again.
This functionality is mainly useful for the CBU imaging setup, where nothing is on the
path by default (and we want to be able to increment the version of these dependencies
together with the conda environment releases).

# Optional shell environment dependencies
To make full use of the packages in the environment, you may want the following on your
system path:

* SPM 12 / Matlab r2018a
* ANTS
* Freesurfer
* FSL

Historically we tried to set these to specific versions by manipulating the user's path
during `conda activate`, but this turned out to be a bad idea (see #1).

# Dealing with firewall issues with HTTPS / SSL connections in git, conda, urllib3
If, like us, you are unlucky enough to sit behind a firewall with HTTPS inspection, you
will need need to set a few environment variables to get HTTPS connectivity for git and
packages that depend on urllib3 / requests. I recommend
setting [`REQUESTS_CA_BUNDLE`](https://stackoverflow.com/a/37447847/3375155) and 
[`GIT_SSL_CAINFO`](https://www.git-scm.com/docs/git-config/#Documentation/git-config.txt-httpsslCAInfo)
to point to your site-specific certificate.

# FAQ
* _Can I use it on Mac or Windows?_ No. We use multiple packages that are only available
  under Linux on Conda. You could probably put the environment into a
  [Neurodocker](https://github.com/kaczmarj/neurodocker) container though.
* _I can't find package *X*_ Pull requests are welcome! We aim for inclusivity, so
  barring conflicting dependencies anything neuro-related goes.
* _This is not how you're meant to use environments_ That's not a question, but you're
  right. If you're a developer you probably want to a separate environment for each
  project you work on rather than a single monolith. But if you're a data analyst, you
  may value productivity and easy reproducibility over control over the exact package
  versions you use. Neuroconda is aimed at the latter group, much like Anaconda.

# Problems
Please contact Johan Carlin or open an issue.
