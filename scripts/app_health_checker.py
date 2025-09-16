#!/usr/bin/env python3
import argparse
import requests
import sys
from datetime import datetime

def check_health(url, timeout=10):
    try:
        response = requests.get(url, timeout=timeout)
        status = response.status_code
        if 200 <= status < 300:
            print(f"[{datetime.now()}] UP: {url} returned {status}")
            return True
        else:
            print(f"[{datetime.now()}] DOWN: {url} returned {status} (expected 200-299)")
            return False
    except requests.exceptions.RequestException as e:
        print(f"[{datetime.now()}] DOWN: {url} - {e}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Check app health via HTTP status")
    parser.add_argument("--url", required=True, help="URL to check")
    parser.add_argument("--threshold", type=int, default=200, help="Expected status code threshold")
    args = parser.parse_args()

    if check_health(args.url):
        sys.exit(0)
    else:
        sys.exit(1)