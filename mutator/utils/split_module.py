import argparse
import os
import sys
import json
import typing
from pathlib import Path

import libcst as cst

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import visitors.function_body_visitor as fbv  # noqa: E402


def output(
    path: str,
    result: fbv.FunctionBodyCollector.Result,
    repository: str = None,
    revision: str = None,
):
    payload = []

    for (class_name, function_name), item in result.data.items():
        identifier = {
            "repositoryURL": repository,
            "revision": revision,
            "fileName": str(path),
            "className": class_name,
            "functionName": function_name,
            "functionStart": item.start,
            "functionEnd": item.end,
        }
        identifier = {k: v for k, v in identifier.items() if v}
        payload.append({"identifier": identifier, "item": item.body})

    return payload


def split(
    filepath: str,
    repository: typing.Optional[str] = None,
    revision: typing.Optional[str] = None,
):
    with open(filepath, "r") as source:
        data = source.read()
        source_tree = cst.metadata.MetadataWrapper(cst.parse_module(data))
        visitor = fbv.FunctionBodyCollector()
        source_tree.visit(visitor)

        return output(filepath, visitor.result, repository, revision)
