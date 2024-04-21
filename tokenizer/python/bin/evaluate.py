import argparse
import json
import sys
import os.path


sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import evaluator


FILES_TO_PROCESS_GLOB = "*.py"


def main():
    parser = argparse.ArgumentParser(prog="evaluate.py")

    parser.add_argument("directory")
    parser.add_argument("--output")
    parser.add_argument("--identifier", required=True)
    args = parser.parse_args()

    result = evaluator.Evaluator(args.directory, args.identifier).evaluate()
    serialized_result = json.dumps(result)

    if args.output:
        with open(args.output, "w") as device:
            device.write(serialized_result)
    else:
        sys.stdout.write(serialized_result)

if __name__ == "__main__":
    main()
