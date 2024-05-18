import argparse

import benchmarking.executor as benchmarking_executor


class Executor:
    class Action:
        @staticmethod
        def build(type: str, parameters: dict) -> "Executor.Action":
            if type == "benchmark":
                return Executor.Benchmark(parameters)
            if type == "plot":
                return Executor.Plot(parameters)

            raise ValueError(f"Unsupported action type {type}")

        def __init__(self, parameters: dict):
            self.parameters = parameters

        def run(self, state: dict) -> None:
            raise NotImplementedError()

    class Benchmark(Action):
        def run(self, state: dict) -> None:
            recall = benchmarking_executor.process(
                argparse.Namespace(**self.parameters), self.parameters["algorithm"]
            )

            print(recall)

            if "recalls" not in state:
                state["recalls"] = []

            state["recalls"].append(recall)

    class Plot(Action):
        def run(self, state: dict) -> None:
            raise NotImplementedError()

    def __init__(self, configuration: dict) -> None:
        self.configuration = configuration

    def execute(self) -> None:
        state: dict = {}
        actions = list(
            map(
                lambda entry: Executor.Action.build(entry["type"], entry["parameters"]),
                self.configuration["actions"],
            )
        )

        for action in actions:
            action.run(state)

        print("RESULTS")

        for recall in state["recalls"]:
            print("%.2f" % recall)
