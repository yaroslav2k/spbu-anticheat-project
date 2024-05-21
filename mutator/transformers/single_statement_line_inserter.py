from typing import Union

import libcst

from transformers.abstract_transformer import AbstractTransformer


class SingleStatementLineInserter(AbstractTransformer):
    def __init__(self, result: tuple):
        self.result = result

        self.total_nodes_count: int = 0
        self.line_inserted: bool = False

    def leave_SimpleStatementLine(
        self,
        original_node: libcst.SimpleStatementLine,
        updated_node: libcst.SimpleStatementLine,
    ) -> Union[libcst.SimpleStatementLine, libcst.FlattenSentinel]:
        if original_node != self.result[0]:
            return updated_node

        return libcst.FlattenSentinel([self.result[1], updated_node])
