import split_module
import tokenizer
import argparse
import json
import sys
import os.path

from functools import reduce
from pathlib import Path

FILES_TO_PROCESS_GLOB = "*.py"


def main():
    parser = argparse.ArgumentParser(prog="evaluate.py")

    parser.add_argument("directory")
    parser.add_argument("--output")
    parser.add_argument("--identifier", required=True)
    args = parser.parse_args()

    result = call_splitter(args.directory, args.identifier)
    result = tokenizer.tokenize_data(result)
    serialized_result = json.dumps(result)

    if args.output:
        with open(args.output, "w") as device:
            device.write(serialized_result)
    else:
        sys.stdout.write(serialized_result)


def filepaths_to_process(directory: str):
    return map(
        lambda entry: os.path.normpath(entry),
        Path(directory).rglob(FILES_TO_PROCESS_GLOB),
    )


def call_splitter(directory: str, identifier: str):
    return list(
        reduce(
            lambda array, entry: array + split_module.split(entry, identifier),
            filepaths_to_process(directory),
            [],
        )
    )


if __name__ == "__main__":
    main()
