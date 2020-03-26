# GNU Makefile for neuroconda. Commands:
# install (default target): create a new environment from neuroconda.yml
# update: create a new neuroconda.yml by building an environment from
# 	neuroconda_basepackages.yml and exporting.
# uninstall: remove installed environment.
SHELL := bash
# make sure bash exceptions propagate to make
.SHELLFLAGS = -e -c
NEUROCONDA_VERSION ?= neuroconda_2_0
NEUROCONDA_YML ?= neuroconda.yml

# default to first environment directory (tends to be user in centralized installs)
PREFIX ?= $(shell echo `conda info | grep "envs directories" | cut -d ":" -f 2`/)

NEUROCONDA_PATH = $(PREFIX)$(NEUROCONDA_VERSION)
NEUROCONDA_PATH_BUILD = $(PREFIX)neuroconda_build

NEURODOCKER_VERSION ?= 0.6.0

$(NEUROCONDA_PATH):
	{ \
	source $(conda info --base)/etc/profile.d/conda.sh ;\
	conda env create --force -f $(NEUROCONDA_YML) --prefix $(NEUROCONDA_PATH) ;\
	conda activate $(NEUROCONDA_PATH) ;\
	python -c "import cortex" ;\
	sed -i \
	's@build/bdist.linux-x86_64/wheel/pycortex-.*data/data@'$(NEUROCONDA_PATH)'@g' \
	~/.config/pycortex/options.cfg ;\
	jupyter serverextension enable --py jupyterlab_code_formatter ;\
	echo "neuroconda install completed at $(NEUROCONDA_PATH)." ;\
	}

$(NEUROCONDA_YML): neuroconda_basepackages.yml
	{ \
	source $(conda info --base)/etc/profile.d/conda.sh ;\
	conda env create --force -f neuroconda_basepackages.yml --prefix $(NEUROCONDA_PATH_BUILD) ;\
	conda env export --prefix $(NEUROCONDA_PATH_BUILD) -f $(NEUROCONDA_YML) --no-builds ;\
	sed -i 's@null@$(NEUROCONDA_VERSION)@' $(NEUROCONDA_YML) ;\
	sed -i '/prefix:/d' $(NEUROCONDA_YML) ;\
	sed -i '/.*dcm2bids.*/c\'"`grep Dcm2Bids neuroconda_basepackages.yml`"'' $(NEUROCONDA_YML) ;\
	echo "neuroconda update completed, $(NEUROCONDA_YML) generated." ;\
	}

# TODO - other supporting neuro packages
Dockerfile: $(NEUROCONDA_YML)
	{ \
	docker run --rm kaczmarj/neurodocker:$(NEURODOCKER_VERSION) generate docker \
	--base=neurodebian:stretch --pkg-manager=apt \
	--ndfreeze date=20200325
	--install eog evince tree
	--copy $(NEUROCONDA_YML) /opt/neuroconda.yml \
	--afni version=latest method=binaries \
	--ants version=2.3.1 method=binaries \
	--freesurfer version=6.0.0 method=binaries \
	--fsl version=5.0.11 method=binaries \
	--spm12 version=r7487 method=binaries \
	--vnc passwd=neuroconda start_at_runtime=true geometry=1920x1080 \


	--miniconda create_env=neuroconda yaml_file=/opt/neuroconda.yml > Dockerfile ;\
	}

uninstall:
	{ \
	source $(conda info --base)/etc/profile.d/conda.sh ;\
	conda env remove --yes --prefix $(NEUROCONDA_PATH) ;\
	echo "neuroconda uninstalled from $(NEUROCONDA_PATH)." ;\
	}

# aliases
install: $(NEUROCONDA_PATH)
update: neuroconda.yml
docker: Dockerfile
.PHONY: update install uninstall
