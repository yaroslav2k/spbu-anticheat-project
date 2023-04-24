#!/bin/bash

set -e

for f in ./data/python/*.py
do
  basename=$(basename $f)
  python mutator/utils/split_module.py ./data/python/${basename} > tmp/fn-defs-${basename}.json
  python tokenizer/tokenizer.py tmp/fn-defs-${basename}.json > tmp/tokens-${basename}.json
done