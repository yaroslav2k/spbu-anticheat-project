import libcst

from visitors.abstract_visitor import AbstractVisitor


class LiteralValuesCollector(AbstractVisitor):
    class Result:
        def __init__(self) -> None:
            self.data: list = []
            self.changes: dict = {}

        def add(self, node: libcst.BaseNumber | libcst.SimpleString) -> None:
            self.data.append(node)

    def __init__(self, target_types: list[type]) -> None:
        self.result = self.Result()
        self.target_types = target_types

    # NOTE: for some reason `visit_BaseNumber` does not work,
    # see https://libcst.readthedocs.io/en/latest/nodes.html#libcst.BaseNumber for details.
    def visit_Integer(self, node: libcst.Integer):
        self.__try_collect_node(node)

    def visit_Float(self, node: libcst.Float):
        self.__try_collect_node(node)

    def visit_Imaginary(self, node: libcst.Imaginary):
        self.__try_collect_node(node)

    def visit_SimpleString(self, node: libcst.SimpleString):
        self.__try_collect_node(node)

    def __try_collect_node(self, node):
        if not self.__ensure_type_is_processable(node):
            return None

        self.result.add(node)

    def __ensure_type_is_processable(self, node):
        return type(node) in self.target_types
