#!/bin/bash

set -ex

python mutator/utils/split_module.py ./data/python/0.py > tmp/data.json
python tokenizer/tokenizer.py tmp/data.json