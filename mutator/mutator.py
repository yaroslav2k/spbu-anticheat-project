import argparse
import sys
import random
import libcst as cst
from contextlib import nullcontext
from dataclasses import dataclass

from mutations.mSDL import mSDL
from mutations.mDL import mDL
from mutations.mSIL import mSIL


def main():
    args = _parse_arguments()
    randomizer = random.Random(args.seed)

    with open(args.input, "r") as source:
        data = source.read()
        source_tree = cst.parse_module(data)

        result = source_tree
        for mutation_spec in args.mutations:
            order = randomizer.randint(
                mutation_spec.lowerbound, mutation_spec.upperbound
            )
            for _ in range(order):
                result = _apply_mutation(mutation_spec.name, result, randomizer)

    _output_result(result, args.output)


def _apply_mutation(name: str, source_tree, randomizer):
    result = None
    match name:
        case "mSDL":
            mutator = mSDL(source_tree, randomizer)
            result = mutator.call()
        case "mDL":
            mutator = mDL(source_tree, randomizer)
            result = mutator.call()
        case "mSIL":
            mutator = mSIL(source_tree, randomizer)
            result = mutator.call()
        case _:
            raise NotImplementedError

    return result


def _parse_arguments():
    parser = argparse.ArgumentParser(
        prog="mutator.py", description="Python CST-based Type-3 mutator"
    )
    parser.add_argument("input")
    parser.add_argument("-o", "--output", action="store")
    parser.add_argument("-m", "--mutations", action="store", required=True)
    parser.add_argument("-s", "--seed", action="store", type=int)

    args = parser.parse_args()
    args.mutations = _parse_mutations_argument(args.mutations)
    if args.seed is None:
        args.seed = random.randint(0, 1000)

    return args


# FIXME: ATM we only support range of length 1.
@dataclass
class MutationSpec:
    name: str
    lowerbound: int = 1
    upperbound: int = 1


# ... mSDL
# ... mSDL:1
# ... mSDL:1,mDL:2
# ... mSDL,mDL:4
def _parse_mutations_argument(raw_input: str):
    mutations = []

    chunks = raw_input.split(",")
    for chunk in chunks:
        if ":" in chunk:
            name, order = chunk.split(":")
            mutations.append(MutationSpec(name, int(order), int(order)))
        else:
            mutations.append(MutationSpec(chunk))

    return mutations


def _output_result(result, output):
    with open(output, "w") if output else nullcontext(sys.stdout) as dest:
        dest.write(result.code)


if __name__ == "__main__":
    main()
