import argparse
import os
import sys
import json
from pathlib import Path

import libcst as cst

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import visitors.function_body_visitor as fbv  # noqa: E402


def output(path, result, repository):
    payload = []

    for (class_name, function_name), item in result.data.items():
        identifier = {
            "repositoryURL": str(repository),
            "fileName": str(path),
            "className": class_name,
            "functionName": function_name,
        }
        payload.append({"identifier": identifier, "item": item})

    return payload


def split(filepath: str, repository: str):
    with open(filepath, "r") as source:
        data = source.read()
        source_tree = cst.parse_module(data)
        visitor = fbv.FunctionBodyCollector()
        source_tree.visit(visitor)

        return output(filepath, visitor.result, repository)
