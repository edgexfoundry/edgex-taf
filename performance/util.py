# util.py
# Define functions
import re, os
from dotenv import load_dotenv

load_dotenv("config.env")

telegraf_host = os.getenv("TELEGRAF_HOST")


def get_token_from_telegraf_conf(file_path):
    try:
        with open(file_path, 'r') as file:
            content = file.read()

        # Regular expression to match the token line
        match = re.search(r'token\s*=\s*["\'](.*?)["\']', content)
        if match:
            return match.group(1)
        else:
            print("Token not found in the configuration file.")
            return None
    except FileNotFoundError:
        print(f"The file {file_path} was not found.")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None


def query_flux(bucket, range, measurement, field, filters, aggregate_range, additional_flux=""):
    base_query = f"""
        from(bucket: "{bucket}")
        |> range(start: -{range})
        |> filter(fn: (r) => r._measurement == "{measurement}")
        |> filter(fn: (r) => r._field == "{field}")
        |> filter(fn: (r) => r.host == "{telegraf_host}")"""
    if filters is not None:
        for key, value in filters.items():
            base_query += f"""
        |> filter(fn: (r) => r.{key} == "{value}")"""
    base_query += f"""
        |> aggregateWindow(every: {aggregate_range}, fn: mean, createEmpty: false)"""
    return base_query + additional_flux

