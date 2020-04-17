# Running neuroconda in a container

We provide two flavours of container. Neuroconda-minimal provides only the conda
packages (currently about 5GB), while Neuroconda-full bundles all the non-conda
neuroimaging packages you might need for an MRI pipeline (about 20GB).

# How to use

On mac, you need to take the following steps

* Unbreak opengl in XQuartz (see [FSLEyes
documentation](https://users.fmrib.ox.ac.uk/~paulmc/fsleyes/userdoc/latest/troubleshooting.html#xquartz-fsleyes-doesn-t-start-and-just-shows-an-error)):

`defaults write org.macosforge.xquartz.X11 enable_iglx -bool true`

* Enable paste with alt-click by [enabling three-button
  emulation](https://www.harrisgeospatial.com/Support/Self-Help-Tools/Help-Articles/Help-Articles-Detail/ArtMID/10220/ArticleID/19900/How-do-I-copy-and-paste-text-from-a-native-Mac-OS-X-application-to-an-X11-based-IDL-widget-program).

* In X11 terminal, first allow connections to localhost (don't know if there is a way to set this globally)

`xhost + 127.0.0.1`

Then fire up container (using any terminal, not necessarily X11), using e.g.

`docker run -e DISPLAY=host.docker.internal:0 -it b3824661d02a`

And in container shell, test with

`fsleyes`

# TODO

* Implement the neuroconda.sh workarounds for e.g. pycortex

* Consider cleaning up Dockerfiles as per [this blog](https://davidrpugh.github.io/stochastic-expatriate-descent/python/conda/docker/data-science/2020/03/31/poor-mans-repo2docker.html)

* Consider setting neuroconda-minimal as the base image for neuroconda-full
