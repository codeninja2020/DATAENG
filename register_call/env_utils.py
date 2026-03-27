import os
from pathlib import Path
from typing import Iterable, Dict


def load_dotenv(path: str = ".env") -> None:
    """
    Lightweight .env loader to avoid an extra dependency.
    Only sets variables that are not already present in the environment.
    """
    env_path = Path(path)
    if not env_path.exists():
        return

    for raw_line in env_path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue

        if line.startswith("export "):
            line = line[len("export ") :].strip()

        if "=" not in line:
            continue

        key, _, value = line.partition("=")
        key = key.strip()
        # Drop surrounding quotes if present
        value = value.strip().strip('"').strip("'")

        if key:
            os.environ.setdefault(key, value)


def require_env(names: Iterable[str]) -> Dict[str, str]:
    """
    Ensure all required env vars are present and return them as a dict.
    Raises RuntimeError listing all missing keys to aid debugging.
    """
    missing = [name for name in names if not os.getenv(name)]
    if missing:
        raise RuntimeError(
            "Missing environment variables: "
            + ", ".join(missing)
            + ". Set them in your shell or a .env file."
        )

    return {name: os.environ[name] for name in names}
