import unittest
import os
import sys
import json

from pathlib import Path
from dataclasses import dataclass

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from evaluator import Evaluator


class TestEvaluator(unittest.TestCase):
    @dataclass
    class TestCase:
        filename: str
        output: str

    def __init__(self, filename: str):
        super().__init__("test_evaluate")

        self.filename = filename

    def test_evaluate(self):
        test_cases = []
        for filepath in os.listdir("fixtures/inputs"):
            test_case = TestEvaluator.TestCase(
                filepath,
                Path("fixtures/outputs/" + filepath)
                .with_suffix(".json")
                .read_text()
                .strip(),
            )
            test_cases.append(test_case)

        for case in test_cases:
            actual_output = json.dumps(
                Evaluator(
                    "fixtures/inputs/" + case.filename, identifier="test"
                ).evaluate()
            )

            with self.subTest(label=case.filename):
                self.assertEqual(case.output, actual_output)
