import libcst

from mutations.base import Base
import visitors.literal_values_visitor as lvv
import transformers.literal_value_transformer as lvt


# FIXME: naming should be aligned with python's recommendations
class mRLN(Base):
    TARGET_TYPES: list[type] = [libcst.Integer, libcst.Float, libcst.Imaginary]
    RANDOM_INTEGER_UPPER_BOUND = 1 * 1_000_000

    def call(self) -> libcst.Module:
        visitor = lvv.LiteralValuesCollector(self.TARGET_TYPES)
        self.source_tree.visit(visitor)
        result = visitor.result

        if not len(result.data):
            return self.source_tree

        node = self.randomizer.choice(result.data)
        result.changes[node] = self.__generate_random_number(node)

        transformer = lvt.LiteralValueTransformer(
            result, target_types=self.TARGET_TYPES
        )
        modified_tree = self.source_tree.visit(transformer)

        return modified_tree

    def __generate_random_number(self, node: libcst.CSTNode) -> int | float:
        if type(node) is libcst.Integer:
            return self.__generate_random_integer()
        else:
            return self.__generate_random_float()

    def __generate_random_integer(self):
        return self.randomizer.randint(0, self.RANDOM_INTEGER_UPPER_BOUND)

    def __generate_random_float(self):
        return self.randomizer.random() * pow(10, self.randomizer.randint(0, 5))
