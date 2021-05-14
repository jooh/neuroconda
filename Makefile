# GNU Makefile for neuroconda. Commands:
# install (default target): create a new environment from neuroconda.yml
# update: create a new neuroconda.yml by building an environment from
# 	neuroconda_basepackages.yml and exporting.
# uninstall: remove installed environment.
# docker-minimal: build minimal docker container
# docker-full: build extended docker container
SHELL := bash
# make sure bash exceptions propagate to make
.SHELLFLAGS = -e -c
NEUROCONDA_VERSION ?= neuroconda_dev
NEUROCONDA_YML ?= neuroconda.yml

# default to first environment directory (tends to be user in centralized installs)
PREFIX ?= $(shell echo `conda info | grep "envs directories" | cut -d ":" -f 2`/)

NEUROCONDA_PATH = $(PREFIX)$(NEUROCONDA_VERSION)
NEUROCONDA_PATH_BUILD = $(PREFIX)neuroconda_build

NEURODOCKER_VERSION ?= 0.7.0

# must be a relative to docker/neuroconda-full/
FS_LICENSE_PATH ?= license.txt
FS_VERSION ?= 6.0.0-min

# consider --pull --no-cache if build fails
DOCKER_BUILD_ARG ?= 

# on GH Actions, this variable references the conda install directory (and the line
# below mysteriously fails, I guess conda isn't on path)
CONDA ?= $(shell conda info --base)

MINICONDA_VERSION ?= py38_4.9.2

# yesterday's date because the snapshot for today isn't always available
# and monstrous case because BSD date on OS X has different call syntax
FREEZE_DATE ?= $(shell ./yesterday_crossplatform)

# All these packages makes the 'minimal' container larger, but helps ensure you have
# consistent behaviour in both 
# (also, some kind of mesa is essential for the environment to build due to pyopengl)
APT_PACKAGES = libgl1-mesa-dri 
APT_PACKAGES_FULL = $(APT_PACKAGES) feh gv tree libjpeg62 libgtk2.0-0 libdbus-glib-1-2 \
	       libgl1-mesa-dev libglu1-mesa-dev


$(NEUROCONDA_PATH):
	{ \
	source $(CONDA)/etc/profile.d/conda.sh ;\
	mamba env create --force -f $(NEUROCONDA_YML) --prefix $(NEUROCONDA_PATH) ;\
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
	mamba env create --force -f neuroconda_basepackages.yml --prefix $(NEUROCONDA_PATH_BUILD) ;\
	mamba env export --prefix $(NEUROCONDA_PATH_BUILD) -f $(NEUROCONDA_YML) --no-builds ;\
	sed -i 's@null@$(NEUROCONDA_VERSION)@' $(NEUROCONDA_YML) ;\
	sed -i '/prefix:/d' $(NEUROCONDA_YML) ;\
	sed -i '/.*dcm2bids.*/c\'"`grep Dcm2Bids neuroconda_basepackages.yml`"'' $(NEUROCONDA_YML) ;\
	echo "neuroconda update completed, $(NEUROCONDA_YML) generated." ;\
	}

docker/neuroconda-full/Dockerfile: $(NEUROCONDA_YML) docker/neuroconda-full/$(FS_LICENSE_PATH)
	{ \
	docker run --rm repronim/neurodocker:$(NEURODOCKER_VERSION) generate docker \
	--base=neurodebian:stretch --pkg-manager=apt \
	--ndfreeze date=$(FREEZE_DATE) \
	--install $(APT_PACKAGES_FULL) \
	--afni version=latest method=binaries \
	--ants version=2.3.1 method=binaries \
	--freesurfer version=$(FS_VERSION) method=binaries \
	--copy $(FS_LICENSE_PATH) /opt/freesurfer-$(FS_VERSION)/ \
	--copy neuroconda.yml / \
	--fsl version=6.0.3 method=binaries \
	--spm12 version=r7771 method=binaries \
	--vnc passwd=neuroconda start_at_runtime=true geometry=1920x1080 \
	--miniconda version=$(MINICONDA_VERSION) create_env=neuroconda yaml_file=neuroconda.yml > $@ \
	--add-to-entrypoint ". /opt/freesurfer-$(FS_VERSION)/SetUpFreeSurfer.sh && \
	. /opt/miniconda-$(MINICONDA_VERSION)/etc/profile.d/conda.sh && \
	conda activate neuroconda" \
	|| rm -f $@ ;\
	}

docker-full: docker/neuroconda-full/Dockerfile
	{ \
	cp $(NEUROCONDA_YML) docker/neuroconda-full/ && \
	cd docker/neuroconda-full && \
	docker build -t $(NEUROCONDA_VERSION) $(DOCKER_BUILD_ARG) . ;\
	}

docker/neuroconda-minimal/Dockerfile: $(NEUROCONDA_YML) 
	{ \
	docker run --rm repronim/neurodocker:$(NEURODOCKER_VERSION) generate docker \
	--base=neurodebian:stretch --pkg-manager=apt \
	--ndfreeze date=$(FREEZE_DATE) \
	--install $(APT_PACKAGES) \
	--copy neuroconda.yml / \
	--miniconda version=$(MINICONDA_VERSION) create_env=neuroconda yaml_file=neuroconda.yml > $@ \
	--add-to-entrypoint ". /opt/miniconda-$(MINICONDA_VERSION)/etc/profile.d/conda.sh && \
	conda activate neuroconda" \
	|| rm -f $@ ;\
	}

docker-minimal: docker/neuroconda-minimal/Dockerfile
	{ \
	cp $(NEUROCONDA_YML) docker/neuroconda-minimal/ && \
	cd docker/neuroconda-minimal && \
	docker build -t $(NEUROCONDA_VERSION) $(DOCKER_BUILD_ARG) . ;\
	rm $(NEUROCONDA_YML) ;\
	}


docker/neuroconda-full/$(FS_LICENSE_PATH):
	$(error Error. Provide path to freesurfer license at docker/neuroconda-full/$(FS_LICENSE_PATH))

uninstall:
	{ \
	source $(CONDA)/etc/profile.d/conda.sh ;\
	mamba env remove --yes --prefix $(NEUROCONDA_PATH) ;\
	echo "neuroconda uninstalled from $(NEUROCONDA_PATH)." ;\
	}

# aliases
install: $(NEUROCONDA_PATH)
update: neuroconda.yml
.PHONY: update install uninstall docker-minimal docker-full
