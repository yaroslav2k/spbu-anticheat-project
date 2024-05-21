import argparse

import libcst


def main():
    parser = argparse.ArgumentParser(
        prog="display_cst.py", description="Python source code CST displayer"
    )
    parser.add_argument("input")

    args = parser.parse_args()

    with open(args.input, "r") as source:
        data = source.read()
        source_tree = libcst.parse_module(data)
        print(source_tree)


if __name__ == "__main__":
    main()
