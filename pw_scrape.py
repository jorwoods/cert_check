import argparse
from collections.abc import Sequence
from contextlib import closing
from copy import deepcopy
import logging
import os
import sys

import boto3
from playwright.sync_api import sync_playwright, Playwright
import sweet_logs

try:
    from dotenv import load_dotenv
except ImportError:
    pass
else:
    load_dotenv()

log_config = deepcopy(sweet_logs.config.base_config)
log_config["handlers"]["file"] = {
    "class": "logging.handlers.RotatingFileHandler",
    "formatter": "json",
    "level": "DEBUG",
    "filename": "pw_scrape.log",
    "maxBytes": 10 * 1024 * 1024,
}
log_config["loggers"]["root"]["handlers"].append("file")

sweet_logs.setup_logging(log_config)
logger = logging.getLogger(__name__)

ignore_certs = {"PCAT", "PCED", "PCPP", "PCAP", "PCET", "PCEP"}
REGION = os.getenv("REGION", "us-east-1").replace('"', "")

def parse_args(args: Sequence[str] | None = None) -> argparse.Namespace:
    if args is None:
        args = sys.argv[1:]
    parser = argparse.ArgumentParser()
    parser.add_argument("--test", action="store_true")
    return parser.parse_args(args)

def str_to_bool(s: str) -> bool:
    return s.lower() in {"true", "1"}

def get_certs(playwright: Playwright) -> set[str]:
    with closing(playwright.chromium.launch(
            headless=str_to_bool(os.getenv("HEADLESS", "1"))
        )) as browser:
        logger.debug("Browser launched")
        page = browser.new_page()
        page.goto("https://ums.edube.org/store")
        logger.debug("Navigated to UMS")
        page.locator(".nav-item").filter(has_text="ython").first.click()
        logger.debug("Navigated to Python Certs")
        certs = set()
        query = "span.product-list__item__short-name"
        page.locator(query).first.wait_for(state="visible")
        logger.debug("Python Certs loaded")
        for loc in page.locator(query).all():
            certs.add(loc.inner_text().split("-")[0].strip())
        logger.info(f"Found Python Certs: {certs}")
    return certs - ignore_certs

def notify(subject: str, message: str) -> None:
    logger.debug(f"Sending notification: {subject}: {message}")
    s = boto3.Session(
        aws_access_key_id=os.environ["iam_access_key"].replace('"', ""),
        aws_secret_access_key=os.environ["iam_secret_key"].replace('"', ""),
        region_name=REGION,
    )

    sns = s.client("sns")
    sns.publish(
        TopicArn=os.environ["topic"].replace('"', ""),
        Subject=subject,
        Message=message,
    )

def main() -> None:
    args = parse_args()
    if args.test:
        logger.info("Testing")
        notify("Test", "Test")
        return
    with sync_playwright() as p:
        try:
            certs = get_certs(p)
        except Exception as e:
            logger.exception("Error in Collecting Python Certs")
            notify("Error in Collecting Python Certs", str(e))
        else:
            if certs:
                notify("New Python Certs", "\n".join(certs))
            else:
                logger.info("No new Python Certs found")

if __name__ == "__main__":
    main()
