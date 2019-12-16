A Conda environment for neuroscience. This is a very inclusive environment that covers
pretty much all neuroimaging-related packages you might want to use. Please let us know
if you want to see any additional packages.

The idea with this repo is to provide an open specification of the computing environment
that was used to run a particular analysis. If you report that you used a particular
release of this environment in your manuscript, you are providing a fairly complete
description of your analysis software.

# Usage

If you've never used conda before, you may have to do `conda init`. Then it's on to

```sh
conda activate neuroconda_1_5
```

As convenient as it may be, it is -not- recommended to activate the environment in your
shell login script since this can cause conflicts with e.g. vncserver and other packages
outside the environment, because you are shadowing system libraries.

# Install

The recommended install route is through

``` sh
make install
```
This will take care of some basic setup, including a fix for Pycortex (see below) and
enabling the jupyterlab code formatter extension. Alternatively, you can just create the
environment as usual with conda

``` sh
conda env create -f neuroconda.yml
```

To install in a custom location, set the PREFIX environment variable, e.g.
`PREFIX=~/temp/ make install`.

Note that the neuroconda environment will be created *inside* this directory (unlike the
conda prefix, which is a full path to the desired install location).

## Install at CBU

A central install of Neuroconda is available (do `conda env list` and you should
see the environment). But if you want to your own install (e.g. to add or
update packages yourself), try `make install-cbu`, which takes care of putting a few
additional non-conda packages on your path (e.g. Freesurfer, FSL, ANTs).

## Pycortex initial configuration
If you don't follow the make install route you will have problems with pycortex, which
looks for file paths in the (invalid) build directory instead of the final install
directory. Work around this by first importing pycortex to generate the default config,
and then editing it to look for the subject database and colormaps in the correct
location (note that if you are using this in a centralised install at e.g. CBU, you may
want the subject database to be somewhere you have write access instead):

```sh
python -c "import cortex"
sed -i 's@build/bdist.linux-x86_64/wheel/pycortex-1.0.2.data/data@'"$CONDA_PREFIX"'@g' ~/.config/pycortex/options.cfg
```

## Handling non-conda dependencies
If you want to put particular non-conda packages on your path You may then want to copy
over the shell environment variables (assuming you are in the repo root and you have
activated the environment):

```sh
rsync -rv --exclude '*.swp' etc/ "$CONDA_PREFIX"/etc/
```

The install-cbu target in the Makefile does this for you. If you already have the packages you want to use on your path
(e.g. through adding them in your shell login script) you don't need to add them again.
This functionality is mainly useful for the CBU imaging setup, where nothing is on the
path by default (and we want to be able to increment the version of these dependencies
together with the conda environment releases).

***Please note that this shell environment activation code only works in bash and other
sh-derived shells. This is a known bug in conda, which can be tracked in [this
issue](https://github.com/conda/conda/issues/9304).***

## Suggested non-conda dependencies
To make full use of the packages in the environment, you may want the following on your
system path:

* SPM 12 / Matlab r2019a
* ANTS
* Freesurfer
* FSL

At CBU, we prefer to add these to the path during conda activate in order to control
which versions are used with a particular neuroconda release (see Install above).

# Dealing with firewall issues with HTTPS / SSL connections in git, conda, urllib3
If, like us, you are unlucky enough to sit behind a firewall with HTTPS inspection, you
will need need to set a few environment variables to get HTTPS connectivity for git and
packages that depend on urllib3 / requests. I recommend setting
[`REQUESTS_CA_BUNDLE`](https://stackoverflow.com/a/37447847/3375155) and
[`GIT_SSL_CAINFO`](https://www.git-scm.com/docs/git-config/#Documentation/git-config.txt-httpsslCAInfo)
to point to your site-specific certificate. You may also want to add your certificate to
the ssl_verify option in your .condarc file.

# FAQ
* _Can I use neuroconda on Mac or Windows?_ No. We use multiple packages that are only
  available under Linux on Conda. You could probably put the environment into a
  [Neurodocker](https://github.com/kaczmarj/neurodocker) container though.
* _I can't find package *X*_ Pull requests are welcome! We aim for inclusivity, so
  barring conflicting dependencies anything neuro-related goes.
* _This is not how you're meant to use environments_ That's not a question, but you're
  right. If you're a developer you probably want to use a separate environment for each
  project you work on rather than a single monolith. But if you're a data analyst, you
  may value productivity and easy reproducibility over control over the exact package
  versions you use. Neuroconda is aimed at the latter group, much like Anaconda.
* _Are neuroconda environments fully reproducible?_ No, but we try! Neuroconda pins the
  version of each package it installs, and tries to avoid implicit dependencies. But
  there is nothing to stop the upstream host (pypi, conda-forge, etc) from changing what
  code that version corresponds to next time you build the environment. If you want to
  have stronger guarantees of exact reproducibility you probably need to bundle the
  environment into a container image.

# Problems
Please contact Johan Carlin or open an issue.

# Contributing
Contributors are welcome! Adding a package is done like so:

1. Add the package to neuroconda_basepackages.yml, ideally without any version pinning
2. run `make update` to re-generate a new neuroconda.yml file (including all
   dependencies)
3. Manually intervene to ensure that a) any non-PyPi pip packages have the correct
   install path (by plugging in the path from neuroconda_basepackages.yml), b) there are
   no further pip packages installed that could have been installed with conda instead
   (this happens when a pip package has a dependency that wasn't already satisfied by
   the conda packages). If so, add them to the list in neuroconda_basebackages.yml and
   repeat the update process.
4. Commit, push and submit a pull request.
5. Maintainer to merge and cut new releases, after incrementing the version in
   neuroconda_basepackages.yml and Makefile.

Maintaining large conda environments is hard because the conda solver continues to
exhibit performance issues. [This bioconda
issue](https://github.com/bioconda/bioconda-recipes/issues/13774) has some useful
suggestions for workarounds, as does [this continuum blog
post](https://www.anaconda.com/understanding-and-improving-condas-performance/). I use
the pycroptosat sat_solver in my .condarc, which seems to help a bit.

## TO DO
* neurodocker container
* fully automate build process
* CI
