import argparse
import yaml

from pipeline.executor import Executor


def main():
    parser = argparse.ArgumentParser(
        prog="pipeline", description="Code clones benchmarking pipeline running tool"
    )

    parser.add_argument("-c", "--configuration", type=str, required=True)

    arguments = parser.parse_args()

    with open(arguments.configuration) as file:
        pipeline = yaml.load(file, Loader=yaml.FullLoader)

    Executor(pipeline).execute()


if __name__ == "__main__":
    main()
