from mutations.registry import Registry


class InjectionTrace:
    class Target:
        def __init__(self, class_path: list[str], function_path: list[str]) -> None:
            self.class_path = class_path
            self.function_path = function_path

        def serializable_dictionary(self) -> dict:
            return {"class_path": self.class_path, "function_path": self.function_path}

    class Metadata:
        def __init__(self) -> None:
            self.data: dict[Registry, int] = {}

        def add(self, mutation: Registry) -> None:
            if mutation in self.data:
                self.data[mutation] += 1
            else:
                self.data[mutation] = 1

        def serializable_dictionary(self) -> dict:
            return dict(map(lambda pair: (pair[0].value, pair[1]), self.data.items()))

    def __init__(self) -> None:
        self.data: dict[InjectionTrace.Target, InjectionTrace.Metadata] = {}

    def add(
        self, class_path: list[str], function_path: list[str], mutation: Registry
    ) -> None:
        target = InjectionTrace.Target(
            class_path=class_path, function_path=function_path
        )
        current_metadata = (
            self.data[target]
            if target in self.data.keys()
            else InjectionTrace.Metadata()
        )

        current_metadata.add(mutation)
        self.data[target] = current_metadata

    def serializable_list(self) -> list:
        return list(
            map(
                lambda entry: {
                    **entry[0].serializable_dictionary(),
                    **{"mutations": entry[1].serializable_dictionary()},
                },
                self.data.items(),
            )
        )
