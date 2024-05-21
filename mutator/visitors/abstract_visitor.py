import libcst


class AbstractVisitor(libcst.CSTVisitor):
    class Result:
        def __init__(self) -> None:
            raise NotImplementedError("This method should be overridden")
