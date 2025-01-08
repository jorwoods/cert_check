FROM python:3.12-bookworm

RUN <<EOF
python3 -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
EOF

COPY requirements.txt .
RUN .venv/bin/python -m pip install -r requirements.txt

RUN <<EOF
.venv/bin/playwright install-deps
.venv/bin/playwright install chromium
EOF

COPY pw_scrape.py .
COPY run.sh .

RUN chmod +x run.sh

ENTRYPOINT ["./run.sh"]
