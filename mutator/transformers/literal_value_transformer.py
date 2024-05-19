import libcst

from visitors.literal_values_visitor import LiteralValuesCollector


class LiteralValueTransformer(libcst.CSTTransformer):
    def __init__(
        self, result: LiteralValuesCollector.Result, target_types: list[type]
    ) -> None:
        self.result = result
        self.target_types = target_types

    def leave_Integer(
        self, original_node: libcst.Integer, updated_node: libcst.Integer
    ) -> libcst.Integer:
        modified_node = self.__try_update_node(original_node, updated_node)
        if type(modified_node) is not libcst.Integer:
            raise RuntimeError(
                "Unexpected returned value type, expected `libcst.Integer`"
            )

        return modified_node

    def leave_Float(
        self, original_node: libcst.Float, updated_node: libcst.Float
    ) -> libcst.Float:
        modified_node = self.__try_update_node(original_node, updated_node)
        if type(modified_node) is not libcst.Float:
            raise RuntimeError(
                "Unexpected returned value type, expected `libcst.Float`"
            )

        return modified_node

    def leave_SimpleString(
        self, original_node: libcst.SimpleString, updated_node: libcst.SimpleString
    ) -> libcst.SimpleString:
        modified_node = self.__try_update_node(original_node, updated_node)
        if type(modified_node) is not libcst.SimpleString:
            raise RuntimeError(
                "Unexpected returned value type, expected `libcst.SimpleString`"
            )

        return modified_node

    def __try_update_node(
        self,
        original_node: libcst.Integer | libcst.Float | libcst.SimpleString,
        updated_node: libcst.Integer | libcst.Float | libcst.SimpleString,
    ) -> libcst.Integer | libcst.Float | libcst.SimpleString:
        if type(original_node) not in self.target_types:
            return original_node

        if original_node not in self.result.changes.keys():
            return original_node

        return updated_node.with_changes(value=str(self.result.changes[original_node]))
