import argparse

from benchmarking.executor import process


def main():
    parser = argparse.ArgumentParser(
        prog="benchmarking", description="Code clones benchmarking tool"
    )

    parser.add_argument(
        "-a", "--algorithm", required=True, type=str, choices=("nicad",)
    )
    parser.add_argument("-c", "--count", type=int, default=10)
    parser.add_argument(
        "-m", "--mode", type=str, choices=("direct", "cross"), required=True
    )
    parser.add_argument("-o", "--mutated-folder-path", type=str, default="mutated")
    parser.add_argument("-s", "--mutations-specification", type=str, required=True)
    parser.add_argument("-i", "--iterations-count", type=int, default=1)
    parser.add_argument("folder_path", type=str)

    arguments = parser.parse_args()

    recall = process(arguments, algorithm_name=arguments.algorithm)
    print("%.2f" % (recall))


if __name__ == "__main__":
    main()
