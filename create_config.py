from pathlib import Path

backend_config = Path('backend-config.tfvars')

def main(file: Path = backend_config):
    if not file.exists():
        file.touch()
        print(f"File {file} created")

    config = dict(map(str.strip, line.split('=')) for line in file.read_text().split("\n") if line)
    expected_keys = ['bucket', 'key', 'region',]
    missing_keys = [key for key in expected_keys if key not in config]
    if missing_keys:
        print(f"Missing keys: {missing_keys}")
        for key in missing_keys:
            config[key] = input(f"Enter value for {key}: ")

        file.write_text("\n".join([f'{k} = "{v}"' for k, v in config.items()]))
        print(f"File {file} updated")
    else:
        print(f"File {file} already contains all the expected keys")

if __name__ == '__main__':
    main()

