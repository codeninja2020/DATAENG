import argparse
import sys
from typing import Dict, List

from env_utils import load_dotenv

# Load environment before importing the outbound helper so required vars are present.
load_dotenv()
from makecall_outbound import initiate_outbound_call  # noqa: E402


def parse_call_info(info_args: List[str]) -> Dict[str, str]:
    """
    Convert ["key=value", ...] into a dict; raises on bad input.
    """
    call_info: Dict[str, str] = {}
    for item in info_args:
        if "=" not in item:
            raise ValueError(f"Invalid info '{item}'. Use key=value.")
        key, value = item.split("=", 1)
        key = key.strip()
        if not key:
            raise ValueError(f"Invalid key in '{item}'.")
        call_info[key] = value.strip()
    return call_info


def main() -> None:
    parser = argparse.ArgumentParser(description="Start an outbound Twilio call.")
    parser.add_argument(
        "--to",
        required=True,
        help="+27677789046",
    )
    parser.add_argument(
        "--info",
        action="append",
        default=[],
        help= {"customer name": "Raphel", "reason": "dinner booking","booking_time":"16:00"},
    )
    args = parser.parse_args()

    try:
        call_info = parse_call_info(args.info)
    except ValueError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)

    sid = initiate_outbound_call(args.to, call_info or None)
    print(f"Call started. SID: {sid}")


if __name__ == "__main__":
    main()
