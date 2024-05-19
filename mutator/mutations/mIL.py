import libcst

from mutations.base import Base
import visitors.single_statement_line_collector as sslv
import transformers.single_statement_line_inserter as ssli


# FIXME: naming should be aligned with python's recommendations
class mIL(Base):
    def call(self) -> libcst.Module:
        visitor = sslv.SingleStatementLineCollector()
        self.source_tree.visit(visitor)
        result = visitor.result

        if not result.data:
            return self.source_tree

        nodes: tuple = tuple(self.randomizer.sample(list(result.data.values()), 2))

        transformer = ssli.SingleStatementLineInserter(nodes)

        modified_tree = self.source_tree.visit(transformer)

        return modified_tree
