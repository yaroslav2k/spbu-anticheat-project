from mutations.registry import Registry

from type_definitions.function_path import FunctionPath


class InjectionTrace:
    class Target:
        def __init__(self, function_path: FunctionPath) -> None:
            self.function_path = function_path

        def to_serializable(self) -> str:
            return ".".join(self.function_path)

    class Metadata:
        def __init__(self) -> None:
            self.data: dict[Registry, int] = {}

        def add(self, mutation: Registry) -> None:
            if mutation in self.data:
                self.data[mutation] += 1
            else:
                self.data[mutation] = 1

        def to_serializable(self) -> dict:
            return dict(map(lambda pair: (pair[0].value, pair[1]), self.data.items()))

    def __init__(self) -> None:
        self.data: dict[InjectionTrace.Target, InjectionTrace.Metadata] = {}

    def add(self, function_path: FunctionPath, mutation: Registry) -> None:
        target = InjectionTrace.Target(function_path=function_path)
        current_metadata = (
            self.data[target]
            if target in self.data.keys()
            else InjectionTrace.Metadata()
        )

        current_metadata.add(mutation)
        self.data[target] = current_metadata

    def serializable_list(self) -> dict:
        result: dict = dict()

        for key, value in self.data.items():
            serialized_key = key.to_serializable()

            if serialized_key not in result:
                result[serialized_key] = {}

            serialized_value = list(value.to_serializable().keys())[0]

            if serialized_value not in result[serialized_key]:
                result[serialized_key][serialized_value] = 0

            result[serialized_key][serialized_value] += 1

        return result
