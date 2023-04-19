import argparse
import os
import sys
import json

import libcst as cst

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import visitors.function_body_visitor as fbv  # noqa: E402

def output(result):
    payload = []

    for (class_name, function_name), value in result.data.items():
        payload.append({ "identifier": [class_name, function_name], "item": value })

    data = json.dumps(payload)
    print(data)


def main():
    parser = argparse.ArgumentParser(
        prog="split_module.py", description="Split python module by functions"
    )
    parser.add_argument("input")

    args = parser.parse_args()

    with open(args.input, "r") as source:
        data = source.read()
        source_tree = cst.parse_module(data)
        visitor = fbv.FunctionBodyCollector()
        source_tree.visit(visitor)

        output(visitor.result)


if __name__ == "__main__":
    main()
