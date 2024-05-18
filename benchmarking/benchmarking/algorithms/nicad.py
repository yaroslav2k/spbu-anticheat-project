import argparse
import subprocess
import os
import shutil
import xml.etree.ElementTree as ET

from benchmarking.algorithms.base import Base


class Nicad(Base):
    # FIXME: generate correct result path (which depends on parameters) in runtime.
    NICAD_CROSS_XML_RESULT_PATH = "nicadclones/mutated/mutated_functions-blind-crossclones/mutated_functions-blind-crossclones-0.30.xml"
    NICAD_DIRECT_XML_RESULT_PATH = "nicadclones/mutated/mutated_functions-blind-clones/mutated_functions-blind-clones-0.30.xml"

    def evaluate(
        self,
        arguments: argparse.Namespace,
        origins_folder_path: str,
        mutated_folder_path: str,
    ) -> int:
        if arguments.mode == "direct":
            return self.__evaluate_direct_mode(origins_folder_path, mutated_folder_path)
        elif arguments.mode == "cross":
            return self.__evaluate_cross_mode(origins_folder_path, mutated_folder_path)
        else:
            raise ValueError(f"Unexpected mode {arguments.mode}")

    def __evaluate_direct_mode(
        self, _origins_folder_path: str, mutated_folder_path: str
    ) -> int:
        self.__invoke_nicad(["nicad", "functions", "py", mutated_folder_path])
        return self.__calculate_nicad_outcome(self.NICAD_DIRECT_XML_RESULT_PATH)

    def __evaluate_cross_mode(
        self, origins_folder_path: str, mutated_folder_path: str
    ) -> int:
        if os.path.isdir("nicadclones"):
            shutil.rmtree("nicadclones")
        self.__invoke_nicad(
            ["nicadcross", "functions", "py", mutated_folder_path, origins_folder_path]
        )
        return self.__calculate_nicad_outcome(self.NICAD_CROSS_XML_RESULT_PATH)

    def __invoke_nicad(self, command: list[str]) -> None:
        _process_outcome = subprocess.run(
            command,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    def __calculate_nicad_outcome(self, filepath: str) -> int:
        tree = ET.parse(filepath)
        root = tree.getroot()

        return len(list(filter(lambda x: x.tag == "clone", root)))
