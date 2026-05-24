import json
import os
import subprocess
from datetime import datetime


class PerformanceUtils:
    """Utility keywords for performance metrics collection."""

    def read_json_file(self, filepath):
        """Read and parse a JSON file safely."""
        try:
            with open(filepath, "r") as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError) as e:
            print(f"[read_json_file] Error reading {filepath}: {e}")
            return None

    def write_json_file(self, filepath, data):
        """Write data to a JSON file, creating directories if needed."""
        try:
            self.ensure_directory(os.path.dirname(filepath))
            with open(filepath, "w") as f:
                json.dump(data, f, indent=4)
            return True
        except (OSError, TypeError) as e:
            print(f"[write_json_file] Error writing {filepath}: {e}")
            return False

    def execute_command(self, command, timeout=60):
        """Execute a shell command with timeout support."""
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

    def format_timestamp(self):
        """Generate a timestamp string suitable for file naming."""
        return datetime.now().strftime("%Y%m%d_%H%M%S")

    def ensure_directory(self, dirpath):
        """Create a directory and all parent directories if needed."""
        try:
            if dirpath:
                os.makedirs(dirpath, exist_ok=True)
            return True
        except OSError as e:
            print(f"[ensure_directory] Error creating directory {dirpath}: {e}")
            return False
