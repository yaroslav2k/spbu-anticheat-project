import os
import shutil
import argparse
import subprocess

from benchmarking.algorithms.base import Base
from benchmarking.algorithms.nicad import Nicad


def process(arguments: argparse.Namespace, algorithm_name: str) -> float:
    algorithm = __find_algorithm_adapter(algorithm_name)
    if os.path.isdir("nicadclones"):
        shutil.rmtree("nicadclones")

    if os.path.isdir(arguments.mutated_folder_path):
        shutil.rmtree(arguments.mutated_folder_path)

    target_file_paths = map(
        lambda x: f"{arguments.mutated_folder_path}/{str(x)}.py",
        range(0, arguments.count),
    )

    original_files = os.listdir(arguments.folder_path)
    if len(original_files) != 1:
        raise ValueError("Expected `folder_path` argument to contain exactly one file")
    original_file = f"{arguments.folder_path}/{original_files[0]}"

    total_recall = 0

    for i in range(arguments.iterations_count):
        if not os.path.isdir(arguments.mutated_folder_path):
            os.mkdir(arguments.mutated_folder_path)

        for target_file_path in target_file_paths:
            shutil.copyfile(original_file, target_file_path)

            _process_outcome = subprocess.run(
                [
                    "python",
                    "../mutator/mutator.py",
                    "-o",
                    target_file_path,
                    "-m",
                    arguments.mutations_specification,
                    target_file_path,
                ],
                check=True,
                stdout=subprocess.PIPE,
            )

        matches_count = algorithm.evaluate(
            arguments, arguments.folder_path, arguments.mutated_folder_path
        )

        total_recall += matches_count

    total_count = arguments.iterations_count
    total_count *= arguments.count

    if arguments.mode == "direct":
        total_count *= arguments.count - 1
        total_count /= 2

    print(f"{total_recall} / {total_count}")

    return float(total_recall) / total_count


def __find_algorithm_adapter(algorithm: str) -> Base:
    if algorithm == "nicad":
        return Nicad()
    else:
        raise ValueError(f"Unsupported algorithm {algorithm}")
