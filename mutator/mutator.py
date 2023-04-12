import argparse
import sys
import random
import libcst as cst
from contextlib import nullcontext

from mutations.mSDL import mSDL


def main():
    args = _parse_arguments()

    with open(args.input, "r") as source:
        data = source.read()
        source_tree = cst.parse_module(data)

        result = None
        match args.mutation:
            case "mSDL":
                mutator = mSDL(source_tree, random.Random(args.seed))
                result = mutator.call()
            case _:
                raise NotImplementedError

    _output_result(result, args.output)


def _parse_arguments():
    mutations = ["mSDL"]

    parser = argparse.ArgumentParser(
        prog="mutator.py", description="Python CST-based Type-3 mutator"
    )
    parser.add_argument("input")
    parser.add_argument("-o", "--output", action="store")
    parser.add_argument("-m", "--mutation", choices=mutations, required=True)
    parser.add_argument("-s", "--seed", action="store", type=int)

    args = parser.parse_args()
    if args.seed is None:
        args.seed = random.randint()

    return args


def _output_result(result, output):
    with open(output, "w") if output else nullcontext(sys.stdout) as dest:
        dest.write(result.code)


if __name__ == "__main__":
    main()
