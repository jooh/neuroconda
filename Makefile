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

NEURODOCKER_VERSION ?= 0.7.0

FS_LICENSE = docker/neuroconda-full/license.txt
FS_VERSION ?= 6.0.0-min

# consider --pull --no-cache if build fails
DOCKER_BUILD_ARG ?= 

CONDA ?= $(shell conda info --base)

$(NEUROCONDA_PATH):
	{ \
	source $(CONDA)/etc/profile.d/conda.sh ;\
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
	source $(CONDA)/etc/profile.d/conda.sh ;\
	conda env create --force -f neuroconda_basepackages.yml --prefix $(NEUROCONDA_PATH_BUILD) ;\
	conda env export --prefix $(NEUROCONDA_PATH_BUILD) -f $(NEUROCONDA_YML) --no-builds ;\
	sed -i 's@null@$(NEUROCONDA_VERSION)@' $(NEUROCONDA_YML) ;\
	sed -i '/prefix:/d' $(NEUROCONDA_YML) ;\
	sed -i '/.*dcm2bids.*/c\'"`grep Dcm2Bids neuroconda_basepackages.yml`"'' $(NEUROCONDA_YML) ;\
	echo "neuroconda update completed, $(NEUROCONDA_YML) generated." ;\
	}

# TODO - should use the repo neuroconda.yml, not wget from github
docker/neuroconda-full/Dockerfile: $(NEUROCONDA_YML) $(FS_LICENSE)
	{ \
	docker run --rm repronim/neurodocker:$(NEURODOCKER_VERSION) generate docker \
	--base=neurodebian:stretch --pkg-manager=apt \
	--ndfreeze date=20210114 \
	--install eog evince tree libdbus-glib-1-2 libjpeg62 libgtk2.0-0 \
	--afni version=latest method=binaries \
	--ants version=2.3.1 method=binaries \
	--freesurfer version=$(FS_VERSION) method=binaries \
	--copy $(FS_LICENSE) /opt/freesurfer-$(FS_VERSION)/ \
	--fsl version=6.0.3 method=binaries \
	--spm12 version=r7771 method=binaries \
	--vnc passwd=neuroconda start_at_runtime=true geometry=1920x1080 \
	--run 'wget https://github.com/jooh/neuroconda/raw/v2.0/neuroconda.yml' \
	--miniconda version=4.9.2 create_env=neuroconda yaml_file=neuroconda.yml > $@ \
	--add-to-entrypoint ". /opt/freesurfer-$(FS_VERSION)/SetUpFreeSurfer.sh && \
	. /opt/miniconda-latest/etc/profile.d/conda.sh && \
	conda activate neuroconda" \
	|| rm -f $@ ;\
	}

docker-full: docker/neuroconda-full/Dockerfile
	{ \
	cd docker/neuroconda-full && \
	docker build $(DOCKER_BUILD_ARG) . ;\
	}

docker/neuroconda-minimal/Dockerfile: $(NEUROCONDA_YML) 
	{ \
	docker run --rm repronim/neurodocker:$(NEURODOCKER_VERSION) generate docker \
	--base=neurodebian:stretch --pkg-manager=apt \
	--ndfreeze date=20210114 \
	--run 'wget https://github.com/jooh/neuroconda/raw/v2.0/neuroconda.yml' \
	--miniconda version=4.9.2 create_env=neuroconda yaml_file=neuroconda.yml > $@ \
	--add-to-entrypoint ". /opt/miniconda-latest/etc/profile.d/conda.sh && \
	conda activate neuroconda" \
	|| rm -f $@ ;\
	}

$(FS_LICENSE):
	$(error Error. Provide path to freesurfer license at $(FS_LICENSE))

uninstall:
	{ \
	source $(CONDA)/etc/profile.d/conda.sh ;\
	conda env remove --yes --prefix $(NEUROCONDA_PATH) ;\
	echo "neuroconda uninstalled from $(NEUROCONDA_PATH)." ;\
	}

# aliases
install: $(NEUROCONDA_PATH)
update: neuroconda.yml
.PHONY: update install uninstall docker-minimal docker-full
