import random
import libcst

from mutations.base import Base
import visitors.single_statement_line_collector as sslv
import transformers.single_statement_line_remover as sslr


# FIXME: naming should be aligned with python's recommendations
class mDL(Base):
    def call(self) -> libcst.Module:
        visitor = sslv.SingleStatementLineCollector()
        self.source_tree.visit(visitor)
        result = visitor.result

        nodes_for_deletion = {}
        if len(result.data.items()) > 0:
            node_hash, node = random.choice(list(result.data.items()))
            nodes_for_deletion[node_hash] = node
        else:
            return self.source_tree

        transformer = sslr.SingleStatementLineRemover(nodes_for_deletion)
        modified_tree = self.source_tree.visit(transformer)

        return modified_tree
