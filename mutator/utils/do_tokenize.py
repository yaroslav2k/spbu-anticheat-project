import sys
import json

import split_module
import tokenizer


def main():
    data = split_module.split(sys.argv[1])

    print(json.dumps(tokenizer.tokenize_data(data)))


if __name__ == "__main__":
    main()
