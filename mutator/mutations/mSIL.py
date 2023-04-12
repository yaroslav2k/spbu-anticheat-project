import string

from typing import Tuple
from mutations.base import Base

import visitors.function_definition_visitor as fdv
import transformers.function_definition_transformer as fdt
import libcst as cst


class mSIL(Base):
    def call(self):
        visitor = fdv.FunctionDefinitionCollector()
        self.source_tree.visit(visitor)

        result = visitor.result
        self._add_parameter(result)

        transformer = fdt.FunctionDefinitionTransformer(result)
        modified_tree = self.source_tree.visit(transformer)

        return modified_tree

    def _add_parameter(
            self, result: fdv.FunctionDefinitionCollector.Result, typehint_prob: float = 0.5, value_prob: float = 0.3
            ) -> None:
        function_spec, parameters = self.randomizer.choice(list(result.data.items()))
        params = list(parameters.params)

        name = self._generate_name()
        new_param = cst.Param(cst.Name(name))
        new_position = self.randomizer.randint(0, len(params))

        typehint, default_value = TypehintGenerator.generate_typehint_and_default_value(self.randomizer)

        if new_position > 0 and params[new_position - 1].default is not None:
            new_param = new_param.with_changes(default=default_value)
        elif new_position < len(params) and params[new_position].default is None:
            new_param = new_param.with_changes(default=None)
        elif self.randomizer.random() < value_prob:
            new_param = new_param.with_changes(default=default_value)

        if self.randomizer.random() < typehint_prob:
            new_param = new_param.with_changes(annotation=typehint)

        params.insert(new_position, new_param)
        result.data[function_spec] = parameters.with_changes(params=tuple(params))

    def _generate_name(self, min_len: int = 1, max_len: int = 10) -> str:
        name_len = self.randomizer.randint(min_len, max_len)
        first_letter = self.randomizer.choice(string.ascii_letters)
        name_tail = ''.join(self.randomizer.choice(string.ascii_letters + string.digits + '_')
                            for i in range(name_len-1))
        return first_letter + name_tail


class TypehintGenerator:
    _basic_types = ["int", "float", "str"]
    _compound_types = ["List", "Tuple"]  # todo add "Dict" and "Set"

    @classmethod
    def generate_typehint_and_default_value(cls, randomizer) -> Tuple[cst.Annotation, cst.CSTNode]:
        typehint = randomizer.choice(cls._basic_types + cls._compound_types)
        if typehint in cls._basic_types:
            return cls._generate_basic_typehint_and_value(typehint, randomizer)
        return cls._generate_compound_typehint_and_value(typehint, randomizer)

    @classmethod
    def _generate_basic_typehint_and_value(cls, basic_type: str, randomizer) -> Tuple[cst.Annotation, cst.CSTNode]:
        typehint = cst.Annotation(cst.Name(basic_type))
        match basic_type:
            case "int":
                value = str(randomizer.randint(0, 1000000))
                return typehint, cst.Integer(value)
            case "str":
                allowed_symbols = string.ascii_letters + string.digits + "#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
                length = randomizer.randint(0, 20)
                value = '"' + ''.join(randomizer.choice(allowed_symbols) for i in range(length)) + '"'
                return typehint, cst.SimpleString(value)
            case "float":
                value = str(randomizer.random()*randomizer.randint(0, 1000))
                return typehint, cst.Float(value)

    @classmethod
    def _generate_compound_typehint_and_value(
        cls, compound_type: str, randomizer
    ) -> Tuple[cst.Annotation, cst.CSTNode]:
        elements = []
        match compound_type:
            case "List":
                basic_type = randomizer.choice(cls._basic_types)
                length = randomizer.randint(0, 6)
                for _ in range(length):
                    _, value = cls._generate_basic_typehint_and_value(basic_type, randomizer)
                    elements.append(cst.Element(value))
                typehint = cst.Annotation(cst.Subscript(
                    cst.Name("List"), [cst.SubscriptElement(cst.Index(cst.Name(basic_type)))]))
                return typehint, cst.List(elements)
            case "Tuple":
                slice = []
                length = randomizer.randint(1, 3)
                for _ in range(length):
                    basic_type = randomizer.choice(cls._basic_types)
                    _, value = cls._generate_basic_typehint_and_value(basic_type, randomizer)
                    elements.append(cst.Element(value))
                    slice.append(cst.SubscriptElement(cst.Index(cst.Name(basic_type))))

                return cst.Annotation(cst.Subscript(cst.Name("Tuple"), slice)), cst.Tuple(elements)
