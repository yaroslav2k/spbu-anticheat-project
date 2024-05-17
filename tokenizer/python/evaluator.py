import os.path
from functools import reduce
from pathlib import Path

import split_module
import tokenizer


class Evaluator:
    FILES_TO_PROCESS_GLOB = "*.py"

    def __init__(self, directory: str, identifier: str) -> None:
        self.directory = directory
        self.identifier = identifier

    def evaluate(self) -> str:
        result = self.call_splitter(self.directory, self.identifier)
        result = tokenizer.tokenize_data(result)

        return result

    def call_splitter(self, directory: str, identifier: str):
        return list(
            reduce(
                lambda array, entry: array
                + split_module.split(entry, directory, identifier),
                self.filepaths_to_process(directory),
                [],
            )
        )

    def filepaths_to_process(self, directory: str):
        if os.path.isfile(directory):
            return [directory]

        return map(
            lambda entry: os.path.normpath(entry),
            Path(directory).rglob(self.FILES_TO_PROCESS_GLOB),
        )
