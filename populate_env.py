from pathlib import Path
import re
import subprocess

def populate_env():
    folder = Path(__file__).parent
    outputs = {}
    for file in folder.glob("*.tf"):
        with file.open() as f:
            for line in f:
                if (match := re.match(r'^output "(.+)" {', line)):
                    outputs[match.group(1)] = None

    for output in outputs:
        value = subprocess.check_output(["terraform", "output", output]).decode().strip()
        outputs[output] = value

    with (folder / ".env").open("w") as f:
        for output, value in outputs.items():
            f.write(f"{output}={value}\n")

if __name__ == "__main__":
    populate_env()
