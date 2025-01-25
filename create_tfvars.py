from pathlib import Path

tfvars = Path("terraform.tfvars")

def main(file: Path = tfvars):
    if 'subscribers' in file.read_text():
        return

    subscribers = input("Enter the emails of users to subscribe, separated by spaces: ").split()
    with file.open('a') as f:
        f.write(f'subscribers = {subscribers}\n')


if __name__ == '__main__':
    main()
