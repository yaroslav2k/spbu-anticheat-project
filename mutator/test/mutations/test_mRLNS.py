import unittest
import os
import random
import sys
import libcst as cst

from pathlib import Path
from dataclasses import dataclass

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from mutations.mRLS import mRLS


class TestmRLS(unittest.TestCase):
    @dataclass
    class TestCase:
        filename: str
        output: str

    def __init__(self, filename: str):
        super().__init__("test_call")

        self.maxDiff = None
        self.filename = filename

    def test_call(self):
        randomizer = random.Random(44)

        test_cases = []
        for filepath in os.listdir("test/fixtures/mRLS/inputs"):
            test_case = TestmRLS.TestCase(
                filepath,
                Path("test/fixtures/mRLS/outputs/" + filepath)
                .with_suffix(".py")
                .read_text()
                .strip(),
            )
            test_cases.append(test_case)

        for case in test_cases:
            with open(f"test/fixtures/mRLS/inputs/{case.filename}", "r") as source:
                source_tree = cst.parse_module(source.read())

                actual_output = source_tree

                for _ in range(2):
                    actual_output = mRLS(actual_output, randomizer).call()

                with self.subTest(label=case.filename):
                    self.assertEqual(case.output, actual_output.code.strip())
