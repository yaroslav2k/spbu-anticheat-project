import unittest
import os
import random
import sys
import json
import libcst as cst

from pathlib import Path
from dataclasses import dataclass

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from mutations.mSDL import mSDL


class TestmSDL(unittest.TestCase):
    @dataclass
    class TestCase:
        filename: str
        output: str

    def __init__(self, filename: str):
        super().__init__("test_call")

        self.maxDiff = None
        self.filename = filename

    def test_call(self):
        randomizer = random.Random(42)

        test_cases = []
        for filepath in os.listdir("test/fixtures/mSDL/inputs"):
            test_case = TestmSDL.TestCase(
                filepath,
                Path("test/fixtures/mSDL/outputs/" + filepath)
                .with_suffix(".py")
                .read_text()
                .strip(),
            )
            test_cases.append(test_case)

        for case in test_cases:
            with open(f"test/fixtures/mSDL/inputs/{case.filename}", "r") as source:
                source_tree = cst.parse_module(source.read())

                actual_output = mSDL(source_tree, randomizer).call().code
                if "4" in case.filename:
                    print(actual_output)

                # with self.subTest(label=case.filename):
                #     self.assertEqual(case.output, actual_output.strip())
