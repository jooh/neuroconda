#!/bin/bash

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate neuroconda

exec "$@"
