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
conda activate neuroconda_2_0
```

As convenient as it may be, it is -not- recommended to activate the environment in your
shell login script since this can cause conflicts with e.g. vncserver and other packages
outside the environment, because you are shadowing system libraries.

## CBU users

Users at MRC CBU may want to use shell script wrappers for activating neuroconda. These
also take care of adding various non-conda dependencies to the path (e.g., Matlab,
SPM12, ANTs, FSL, Freesurfer). If you are not at CBU, you may find it useful to write
your own versions of these wrappers.

``` csh
source neuroconda.csh
```

Or if you are using sh-derived shells like bash:

``` bash
source neuroconda.sh
```

We currently don't supply *de-activation* wrapper scripts (PRs welcome!) so it's
probably safest to start a fresh shell session every time you want to switch neuroconda
versions (the standard conda deactivate route will take care of conda packages but will
leave the non-conda dependencies on your path).

# Install

The recommended install route is through

``` sh
make
```

To install in a custom location, set the PREFIX environment variable, e.g.
`PREFIX=~/temp/ make`. Note that the neuroconda environment will be created *inside*
this directory (unlike the conda `prefix` argument, which is a full path to the desired
install location).

The make route takes care of some basic setup, including a fix for Pycortex (see below)
and enabling the jupyterlab code formatter extension. Alternatively, you can just create
the environment as usual with conda

``` sh
conda env create -f neuroconda.yml
```

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

## Suggested non-conda dependencies
To make full use of the packages in the environment, you may want the following on your
system path:

* SPM 12 / Matlab r2019a
* ANTS
* Freesurfer
* FSL

In past releases we used conda's [env_vars.{sh,csh}
functionality](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#saving-environment-variables)
to add non-conda packages to the path, but this part of conda is profoundly broken at
the moment ([csh works not at all](https://github.com/conda/conda/issues/9304),
[restoring the path during deactivate doesn't
work](https://github.com/conda/conda/issues/3915)). The workaround for now is to create a shell script
wrapper that takes care of adding non-conda packages to the path *before* activating the
environment. For examples that we use at CBU, see [neuroconda.sh](neuroconda.sh) and
[neuroconda.csh](neuroconda.csh).

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
* _Are neuroconda environments fully reproducible?_ We try to get as close to full
  reproducibility as we can given that the environment is built from external sources
  (mainly conda-forge and pypi). We pin versions of all installed packages, but not
  builds since these have a tendency to disappear from conda-forge over time, leading to
  broken environments. Reproducibility is limited by the fact that there is nothing to
  stop the external source from changing what code that version corresponds to next time
  you build the environment. If you want to have stronger guarantees of exact
  reproducibility you probably need to bundle the environment into a container image.
  This would also take care of any non-conda dependencies. The tradeoff being that you
  now have to work inside a container.

# Problems
Please contact Johan Carlin or open an issue.

# For developers
Contributions are welcome! The basic design of neuroconda is to list desired packages in
[neuroconda_basepackages.yml](neuroconda_basepackages.yml) with mininal version pinning.
The [Makefile](Makefile) then takes care of constructing a new
[neuroconda.yml](neuroconda.yml) by building an environment and exporting *with* pinning
(but no builds because these tend to go missing on conda-forge). The benefits of this
two-yml design are 1) that updating is *a lot* faster than simply doing `conda update
--all` in the full environment (and less prone to conflicts); 2) By distinguishing
required base packages from dependencies we can also prune packages that are no longer a
dependency of a base package on update.

## Adding a package to neuroconda
If you just want to see a new package, you would take the
following steps:

1. Add the package to neuroconda_basepackages.yml, ideally without any version pinning.
2. run `make` to re-generate a new neuroconda.yml file (including all
   dependencies).
3. Use e.g. `git diff` to check that the new neuroconda.yml does not contain any new 
   pip packages that could have been installed with conda instead (this happens when a
   pip package has a dependency that wasn't already satisfied by the conda packages). If
   so, add them to the list in neuroconda_basebackages.yml and repeat the update
   process. We try to use conda packages whenever possible.
4. Conversely, check that conda doesn't *uninstall* a conda package in order to install
   a newer pip package. This happens when a pip package requires a newer version than is
   available on conda-forge. In this case, move the package to the pip section in
   conda_basepackages.yml and make a note of this (we may try to move it back later).
4. Commit, push and submit a pull request.
5. Maintainer to merge and cut new releases, after incrementing the version in
   neuroconda_basepackages.yml and README.md.

Maintaining large conda environments is hard because the conda solver continues to
exhibit performance issues. [This bioconda
issue](https://github.com/bioconda/bioconda-recipes/issues/13774) has some useful
suggestions for workarounds, as does [this continuum blog
post](https://www.anaconda.com/understanding-and-improving-condas-performance/). I use
the pycroptosat sat_solver in my .condarc, which seems to help a bit.

## Other worthwhile contributions
* tests (probably just try importing a few packages that are known to be tricky, e.g.
  tensorflow, pycortex)
* neurodocker container
* CI
