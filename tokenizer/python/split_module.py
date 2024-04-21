import argparse
import os
import sys
import typing

import libcst as cst

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import visitors.function_body_visitor as fbv  # noqa: E402


def output(
    path: str,
    result: fbv.FunctionBodyCollector.Result,
    revision: str = None,
):
    payload = []

    for (class_name, function_name), item in result.data.items():
        identifier = {
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
    directory: str,
    revision: typing.Optional[str] = None,
):
    with open(filepath, "r") as source:
        data = source.read()
        source_tree = cst.metadata.MetadataWrapper(cst.parse_module(data))
        visitor = fbv.FunctionBodyCollector()
        source_tree.visit(visitor)

        output_result = output(filepath, visitor.result, revision)

        for entry in output_result:
            entry["identifier"]["fileName"] = os.path.relpath(
                entry["identifier"]["fileName"], directory
            )

        return output_result
