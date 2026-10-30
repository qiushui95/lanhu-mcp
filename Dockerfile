FROM python:3.12-slim-bookworm

WORKDIR /app
ENV PYTHONUNBUFFERED=1 \
    PLAYWRIGHT_BROWSERS_PATH=/opt/playwright \
    PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

# Install the same distributable package tested by CI, including design modules.
# Proxy values can be passed using Docker's standard build proxy arguments.
COPY pyproject.toml README.md LICENSE lanhu_mcp_server.py ./
COPY lanhu_design ./lanhu_design
RUN sed -i \
        -e 's@deb.debian.org/debian@mirrors.tuna.tsinghua.edu.cn/debian@g' \
        -e 's@security.debian.org/debian-security@mirrors.tuna.tsinghua.edu.cn/debian-security@g' \
        /etc/apt/sources.list.d/debian.sources
RUN pip install --no-cache-dir . \
    && playwright install --with-deps chromium \
    && mkdir -p /app/data /app/logs \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8000
CMD ["lanhu-mcp", "--transport", "http", "--host", "0.0.0.0"]
