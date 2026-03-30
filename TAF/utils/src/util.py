"""
Utility functions for EdgeX TAF.

This module provides common utility functions for test operations
including file handling, data processing, and command execution.
"""

import json
import os
import subprocess
from typing import Any, Dict, List, Optional
from datetime import datetime


def read_json_file(filepath: str) -> Dict[str, Any]:
    """
    Read and parse JSON file safely.
    
    Args:
        filepath: Path to the JSON file
        
    Returns:
        Parsed JSON content as dictionary
        
    Raises:
        FileNotFoundError: If file does not exist
        json.JSONDecodeError: If JSON is malformed
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            return json.load(file)
    except FileNotFoundError:
        raise FileNotFoundError(f"JSON file not found: {filepath}")
    except json.JSONDecodeError as error:
        raise json.JSONDecodeError(
            f"Invalid JSON in {filepath}: {error.msg}",
            error.doc,
            error.pos
        )


def write_json_file(filepath: str, data: Dict[str, Any]) -> None:
    """
    Write dictionary to JSON file safely.
    
    Args:
        filepath: Path to output file
        data: Dictionary to write as JSON
        
    Raises:
        IOError: If directory cannot be created or file cannot be written
    """
    try:
        directory = os.path.dirname(filepath)
        if directory:
            os.makedirs(directory, exist_ok=True)
        
        with open(filepath, 'w', encoding='utf-8') as file:
            json.dump(data, file, indent=2, sort_keys=True)
    except IOError as error:
        raise IOError(f"Failed to write JSON to {filepath}: {error}")


def execute_command(command: List[str], timeout: int = 30) -> str:
    """
    Execute shell command and capture output.
    
    Args:
        command: Command and arguments as list (e.g., ['curl', 'http://...'])
        timeout: Maximum execution time in seconds
        
    Returns:
        Command stdout as string
        
    Raises:
        subprocess.TimeoutExpired: If command exceeds timeout
        subprocess.CalledProcessError: If command returns non-zero exit code
    """
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=True
        )
        return result.stdout.strip()
    except subprocess.TimeoutExpired as error:
        raise subprocess.TimeoutExpired(
            f"Command '{' '.join(command)}' timed out after {timeout}s",
            timeout
        )
    except subprocess.CalledProcessError as error:
        raise subprocess.CalledProcessError(
            error.returncode,
            error.cmd,
            output=error.stdout,
            stderr=error.stderr
        )


def format_timestamp() -> str:
    """
    Generate formatted timestamp for file naming.
    
    Returns:
        Timestamp string in YYYYMMDD_HHMMSS format
    """
    return datetime.now().strftime("%Y%m%d_%H%M%S")


def ensure_directory(directory_path: str) -> None:
    """
    Ensure directory exists, create if it doesn't.
    
    Args:
        directory_path: Path to directory
        
    Raises:
        PermissionError: If directory cannot be created
    """
    try:
        os.makedirs(directory_path, exist_ok=True)
    except PermissionError as error:
        raise PermissionError(
            f"Cannot create directory '{directory_path}': {error}"
        )
