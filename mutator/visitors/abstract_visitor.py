import libcst


class AbstractVisitor(libcst.CSTVisitor):
    class Result:
        def __init__(self) -> None:
            self.data: dict = {}
