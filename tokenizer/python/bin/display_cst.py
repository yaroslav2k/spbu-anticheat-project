import argparse
import libcst as cst


def main():
    parser = argparse.ArgumentParser(
        prog="display_cst.py", description="Python source code CST representor"
    )
    parser.add_argument("input")

    args = parser.parse_args()

    with open(args.input, "r") as source:
        data = source.read()
        source_tree = cst.parse_module(data)
        print(source_tree)


if __name__ == "__main__":
    main()
