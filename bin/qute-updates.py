#!/usr/bin/env python3
"""
Misc updates for qutebrowser

File: qute-updates.py

Copyright 2026 Ankur Sinha
Author: Ankur Sinha <sanjay DOT ankur AT gmail DOT com>
"""

import logging
import os
import shlex
import shutil
import subprocess
from contextlib import chdir
from pathlib import Path

import requests
import typer

app = typer.Typer()


logging.basicConfig(format="%(name)s (%(levelname)s) >>> %(message)s\n", level=logging.WARNING)

logger = logging.getLogger("qute_updates")
logger.setLevel(logging.DEBUG)


USERSCRIPTS_DIR=f"{os.getenv('HOME')}/.dotfiles/local/share/qutebrowser/userscripts"
USERSCRIPTS_REPO_PATH="https://raw.githubusercontent.com/qutebrowser/qutebrowser/refs/heads/main/misc/userscripts/"
DICTCLI_REPO_PATH="https://raw.githubusercontent.com/qutebrowser/qutebrowser/refs/heads/main/scripts/"

PDFJS_DIR=f"{os.getenv('HOME')}/.local/share/qutebrowser/"

@app.command()
def update_userscripts():
    """Update userscripts"""
    with chdir(USERSCRIPTS_DIR):
        logger.debug(f"Updating scripts in {USERSCRIPTS_DIR}")
        cwd = Path(".")
        scripts = cwd.glob("*")
        for script in scripts:
            logger.info(f"Working on {script.name}")
            response = requests.get(f"{USERSCRIPTS_REPO_PATH}/{script.name}")
            if not response.ok:
                logger.error(f"Could not download {script.name}")
                logger.error(f"{response.status_code}: {response.reason}")
            else:
                with open(script.name, 'w') as f:
                    f.write(response.text)

@app.command()
def update_dict():
    """Update dictionary"""
    script_name = "dictcli.py"
    with chdir(USERSCRIPTS_DIR):
        logger.info(f"Updating {script_name}")
        response = requests.get(f"{DICTCLI_REPO_PATH}/{script_name}")
        if not response.ok:
            logger.error(f"Could not download {script_name}")
            logger.error(f"{response.status_code}: {response.reason}")
        else:
            with open(script_name, 'w') as f:
                f.write(response.text)

        logger.info("Updating dictionaries")

        cmd = shlex.split(f"python {script_name} remove-old")
        result = subprocess.run(cmd, capture_output=True)
        if result.returncode != 0:
            logger.error(f"Could not run {cmd}")
            logger.error(result.stderr)
        else:
            if len(result.stdout):
                logger.info(result.stdout)

        cmd = shlex.split(f"python {script_name} install en-GB fr-FR hi-IN")
        result = subprocess.run(cmd, capture_output=True)
        if result.returncode != 0:
            logger.error(f"Could not run {cmd}")
            logger.error(result.stderr)
        else:
            if len(result.stdout):
                logger.info(result.stdout)

        cmd = shlex.split(f"python {script_name} update")
        result = subprocess.run(cmd, capture_output=True)
        if result.returncode != 0:
            logger.error(f"Could not run {cmd}")
            logger.error(result.stderr)
        else:
            if len(result.stdout):
                logger.info(result.stdout)

@app.command()
def update_pdfjs():
    """Update pdfjs"""
    logger.info("Updating pdfjs")
    version_end_point = "https://api.github.com/repos/mozilla/pdf.js/releases/latest"
    response = requests.get(version_end_point)
    latest_version = ""
    response_json = ""
    if response.ok:
        response_json = response.json()
        latest_version = response_json.get("tag_name", None)
        if latest_version:
            logger.info(f"Found latest version: {latest_version}")
        else:
            logger.error("Could not get latest version")
            return
    else:
        logger.error("Could not get latest version")
        logger.error(f"{response.status_code}: {response.reason}")
        return

    assets = response_json.get("assets", None)
    assert assets
    for asset in assets:
        d_url = asset.get("browser_download_url")
        if "legacy" in d_url:
            continue

        logger.info(f"Download_url: {d_url}")
        response = requests.get(d_url)
        if not response.ok:
            logger.error(f"Could not download from {d_url}")
            logger.error(f"{response.status_code}: {response.reason}")
        else:
            with chdir(PDFJS_DIR):
                fname = d_url.split("/")[-1]

                with open(fname, 'wb') as f:
                    f.write(response.content)
                logger.info(f"Downloaded {fname} to {PDFJS_DIR}")

                try:
                    os.rename("pdfjs", "pdfjs-old")
                except FileNotFoundError as e:
                    logger.warning(e)

                os.mkdir("pdfjs")
                shutil.unpack_archive(fname, "pdfjs")

            logger.info("PDFJs updated")
            logger.info(f"Please check and remove {PDFJS_DIR}/pdfjs-old and {PDFJS_DIR}/{fname}")

@app.command()
def all():
    """Run all updates """
    update_userscripts()
    update_dict()
    update_pdfjs()

if __name__ == "__main__":
    app()
