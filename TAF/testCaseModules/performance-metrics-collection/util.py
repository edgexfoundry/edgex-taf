import json
import os
import subprocess
import sys
from datetime import datetime


def read_json_file(filepath):
    """Read and parse a JSON file safely.

    Args:
        filepath (str): Path to the JSON file.

    Returns:
        dict: Parsed JSON data, or None if an error occurs.
    """
    try:
        with open(filepath, "r") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"[read_json_file] Error reading {filepath}: {e}")
        return None


def write_json_file(filepath, data):
    """Write data to a JSON file, creating directories if needed.

    Args:
        filepath (str): Path to the output JSON file.
        data (dict): Data to serialize and write.

    Returns:
        bool: True if successful, False otherwise.
    """
    try:
        ensure_directory(os.path.dirname(filepath))
        with open(filepath, "w") as f:
            json.dump(data, f, indent=4)
        return True
    except (OSError, TypeError) as e:
        print(f"[write_json_file] Error writing {filepath}: {e}")
        return False


def execute_command(command, timeout=60):
    """Execute a shell command with timeout support.

    Args:
        command (str): Shell command to execute.
        timeout (int): Timeout in seconds (default 60).

    Returns:
        tuple: (stdout, stderr, returncode)
    """
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return result.stdout, result.stderr, result.returncode
    except subprocess.TimeoutExpired as e:
        print(f"[execute_command] Command timed out: {command}")
        return "", str(e), 1
    except Exception as e:
        print(f"[execute_command] Unexpected error: {e}")
        return "", str(e), 1


def format_timestamp():
    """Generate a timestamp string suitable for file naming.

    Returns:
        str: Timestamp in YYYYMMDD_HHMMSS format.
    """
    return datetime.now().strftime("%Y%m%d_%H%M%S")


def ensure_directory(dirpath):
    """Create a directory and all parent directories if they don't exist.

    Args:
        dirpath (str): Path to the directory to create.

    Returns:
        bool: True if successful, False otherwise.
    """
    try:
        if dirpath:
            os.makedirs(dirpath, exist_ok=True)
        return True
    except OSError as e:
        print(f"[ensure_directory] Error creating directory {dirpath}: {e}")
        return False
