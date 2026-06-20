import hmac
import json
import logging
import os

import boto3
from botocore.exceptions import ClientError


LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

SECRETS_MANAGER = boto3.client("secretsmanager")


def _secret_name(username):
    return f"{os.environ['TRANSFER_USER_SECRET_PREFIX']}/{username}"


def _load_user(username):
    try:
        response = SECRETS_MANAGER.get_secret_value(SecretId=_secret_name(username))
    except ClientError as error:
        error_code = error.response.get("Error", {}).get("Code")
        if error_code == "ResourceNotFoundException":
            LOGGER.info("Transfer user %s not found", username)
            return None
        raise

    return json.loads(response["SecretString"])


def _build_response(user_config, include_public_keys):
    response = {
        "Role": user_config["Role"],
    }

    if user_config.get("HomeDirectory"):
        response["HomeDirectory"] = user_config["HomeDirectory"]

    if user_config.get("HomeDirectoryType"):
        response["HomeDirectoryType"] = user_config["HomeDirectoryType"]

    if user_config.get("HomeDirectoryDetails"):
        response["HomeDirectoryDetails"] = user_config["HomeDirectoryDetails"]

    if include_public_keys:
        response["PublicKeys"] = user_config.get("PublicKeys", [])

    if user_config.get("Policy"):
        response["Policy"] = user_config["Policy"]

    return response


def lambda_handler(event, _context):
    username = event.get("username")
    password = event.get("password", "")
    protocol = event.get("protocol")

    if not username:
        return {}

    if protocol and protocol != "SFTP":
        LOGGER.warning("Unsupported protocol %s for user %s", protocol, username)
        return {}

    user_config = _load_user(username)
    if user_config is None:
        return {}

    if password:
        configured_password = user_config.get("Password")
        if not configured_password:
            LOGGER.info("Password auth attempted for user %s without configured password", username)
            return {}

        if not hmac.compare_digest(password, configured_password):
            LOGGER.info("Password auth failed for user %s", username)
            return {}

        return _build_response(user_config, include_public_keys=False)

    public_keys = user_config.get("PublicKeys", [])
    if not public_keys:
        LOGGER.info("Public key auth attempted for user %s without configured keys", username)
        return {}

    return _build_response(user_config, include_public_keys=True)
