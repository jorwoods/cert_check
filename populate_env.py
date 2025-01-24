import json
from pathlib import Path

def populate_env():
    folder = Path(__file__).parent
    with (folder / "output.json").open() as f:
        outputs = json.load(f)

    with (folder / ".env").open("w") as f:
        for output, inner in outputs.items():
            value = inner["value"]
            f.write(f"{output}={value}\n")

if __name__ == "__main__":
    populate_env()
