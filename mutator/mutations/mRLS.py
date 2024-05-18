import pathlib
from typing import Optional, List

import libcst

from mutations.base import Base
import visitors.literal_values_visitor as lvv
import transformers.literal_value_transformer as lvt


# FIXME: naming should be aligned with python's recommendations
class mRLS(Base):
    TARGET_TYPES: list[type] = [libcst.SimpleString]

    __literal_values: Optional[List[str]] = None

    def call(self) -> libcst.Module:
        visitor = lvv.LiteralValuesCollector(self.TARGET_TYPES)
        self.source_tree.visit(visitor)
        result = visitor.result

        if not len(result.data):
            return self.source_tree

        node = self.randomizer.choice(result.data)
        result.changes[node] = self.__generate_random_simple_string_value()

        transformer = lvt.LiteralValueTransformer(
            result, target_types=self.TARGET_TYPES
        )
        modified_tree = self.source_tree.visit(transformer)

        return modified_tree

    def __generate_random_simple_string_value(self) -> str:
        if self.__class__.__literal_values is None:
            with open(
                pathlib.Path(__file__).parent / "data" / "parameter-names-registry.txt"
            ) as f:
                self.__class__.__literal_values = list(
                    filter(len, f.read().split("\n"))
                )

        literal_value = self.randomizer.choice(self.__class__.__literal_values)

        return f'"{literal_value}"'
