import argparse


class Base:
    def evaluate(
        self,
        arguments: argparse.Namespace,
        _origins_folder_path: str,
        _mutated_folder_path: str,
    ) -> int:
        raise NotImplementedError()
