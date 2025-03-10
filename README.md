# Cert check

This repository will check if Python Institute has any new certifications
available. If there is a new certification, it will send an email to the
specified email address by way of AWS Simple Notification Service (SNS).

## Requirements

- Python 3.9+
- [Terraform 1.9+](https://developer.hashicorp.com/terraform/install)
- [Task](https://taskfile.dev/installation/#install-script)
- AWS account

## Setup

1. Clone the repository:

```bash
git clone jorwoods/cert-check
cd cert-check
```

2. Have AWS credentials set up on your machine. You can do this by running
`aws configure` and entering your AWS access key ID and secret access key.

3. Use `task` to prepare terraform to run. This will create a `terraform.tfvars`
and a `backend-config.tfvars` file in the directory. You will be prompted to
fill out information like the s3 bucket to store your tf state, the key for
the tfstate within that bucket, and what region the state is in. You will also
be prompted for what email address[es] you would like to receive notifications
when a new certification is available.

```bash
task init
```

4. Run `task apply` to create the necessary resources in AWS. This will create
an SNS topic, a user that can publish to that topic, and the user's access keys.

5. Run `task dotenv` to create a .env file. This .env file will contain the
credentials as well as the name for the topic that was created for the purposes
of publishing.

The taskfile is set up to know dependencies and will run the necessary tasks
in the correct order. You can directly run `task dotenv` and Task will ensure
that `task init` and `task apply` are automatically run first.

## Deployment

To deploy to a local environment or VM, you need to run the following commands:

### Local or VM
```bash
# Create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install the requirements
pip install -r requirements.txt

# Install playwright's browser
.venv/bin/playwright install-deps
.venv/bin/playwright install chromium

# Run the script
python pw_scrape.py
```

### Docker
```bash
# build the image
docker build -t cert-check .

# run the image
docker run --env-file .env cert-check
```

## Rationale

### Why playwright?

Playwright is a powerful tool that allows for browser automation. It is used
in this project to allow the JavaScript on the Python Institute's website to
run and populate the page with the necessary information. This information is
then scraped and compared to the information stored in the `certs.txt` file.

### Why NOT Lambda?

Lambda is a great tool for running small, short-lived functions. However, the
Playwright library is quite large and would be cumbersome to package up and
deploy to Lambda. You could use the ability to deploy an entire container to
Lambda, but due to the size of the container, that ended up costing more than
the service was worth for this project.

## File Structure

.
├── backend-config.tfvars # Terraform backend configuration file
├── create_config.py      # Script to create the backend-config.tfvars file
├── create_tfvars.py      # Script to create the terraform.tfvars file
├── dockerfile            # Dockerfile if you want to run the script in a container
├── main.tf               # Terraform main configuration file
├── output.tf             # Terraform output specifications
├── populate_env.py       # Turns the terraform output into a .env file
├── pw_scrape.py          # Python script that uses playwright to scrape the site.
├── README.md
├── requirements.txt      # Python dependencies
├── run.sh                # Shell script to run the Python script in a virtual environment
├── Taskfile.yml          # Specifies tasks to run and their dependencies
├── terraform.tfvars      # Values for terraform variables
└── variables.tf          # Terraform variable declarations
