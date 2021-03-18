import shutil
import subprocess
import sys
from pathlib import Path

from invoke import task

DIST_DIR = Path("dist")
BUILD_DIR = Path("build")
WARN_VIRTUALENV = True


def get_base_prefix_compat():
    """Get base/real prefix, or sys.prefix if there is none."""
    return getattr(sys, "base_prefix", None) or getattr(sys, "real_prefix", None) or sys.prefix


def in_virtualenv():
    return get_base_prefix_compat() != sys.prefix

def check_virtualenv():
    if not in_virtualenv() and WARN_VIRTUALENV:
        print(
            "\033[93mWARNING: Not running in virtual environment. Dependencies might not be installed. Activate the virtual environment by running 'poetry shell'\033[0m"
        )

def run(args):
    if not in_virtualenv():
        args = ["poetry", "run"] + args
    subprocess.run(args, shell=True)

@task
def install(c):
    """ Install dependencies and setup project """

    c.run("poetry lock -n")
    c.run("poetry install -n")
    c.run("poetry run pre-commit install")


@task
def format(c):
    """ Format files """

    check_virtualenv()
    run(["black", ".", "--config", "pyproject.toml"])
    run(["isort", ".", "--settings-path", "pyproject.toml"])


@task
def release(c):
    """ Create a beet release of this project """

    check_virtualenv()
    run(["beet", "--config", "beet-release.json"])


@task
def bump(c, new_version, dry=False):
    """ Bump the version of this project """

    check_virtualenv()
    args = ["tbump", new_version]
    if dry:
        args.append("--dry-run")

    run(args)


@task
def clean(c):
    """ Remove generated files and directories  """

    if DIST_DIR.exists():
        shutil.rmtree(DIST_DIR)
    if BUILD_DIR.exists():
        shutil.rmtree(BUILD_DIR)

    run(["beet", "cache", "--clear"])