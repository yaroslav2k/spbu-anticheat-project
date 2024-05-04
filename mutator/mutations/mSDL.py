import libcst as cst

from mutations.base import Base

import visitors.function_definition_visitor as fdv
import transformers.function_definition_transformer as fdt


# FIXME: naming should be aligned with python's recommendations
class mSDL(Base):
    def call(self) -> cst.Module:
        visitor: fdv.FunctionDefinitionCollector = fdv.FunctionDefinitionCollector()
        self._visit(visitor)

        result = visitor.result
        if not result.data:
            return self.source_tree

        self.__select_parameter_for_removal(result)

        transformer = fdt.FunctionDefinitionTransformer(result)
        modified_tree = self.source_tree.visit(transformer)

        return modified_tree

    def __select_parameter_for_removal(self, result) -> None:
        path, parameters_tuple = self.randomizer.choice(list(result.data.items()))
        if not parameters_tuple:
            return

        parameters = list(parameters_tuple)
        parameters.pop(self.randomizer.randrange(len(parameters)))

        result.data[path] = tuple(parameters)
