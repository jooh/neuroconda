# neuroconda-minimal. This image does not include non-conda optional dependencies.
# No effort has been made to support GUI applications (e.g. fsleyes), although
# Jupyter should work.

FROM continuumio/miniconda3:4.8.2

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
RUN ["chmod", "+x", "/usr/local/bin/docker-entrypoint.sh"]

CMD ["/bin/bash"]

RUN apt-get update -qq && \
    apt-get install -y -q --no-install-recommends libgl1-mesa-glx \
    libgl1-mesa-dev \
    libgl1-mesa-dri \
    libglu1-mesa-dev \
    libxcursor1 \
    libxft2 \
    libxinerama1 \
    libxrandr2 \
    libxrender1 \
    libxt6 \
    libxcomposite1 \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/conda\ activate\ base/conda\ activate\ neuroconda/g' ~/.bashrc

RUN wget https://github.com/jooh/neuroconda/raw/v2.0/neuroconda.yml && \
	/opt/conda/bin/conda env create -f neuroconda.yml --name neuroconda && \
	find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
	find /opt/conda/ -follow -type f -name '*.a' -delete && \
	/opt/conda/bin/conda clean -ay
