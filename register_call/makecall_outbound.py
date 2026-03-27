import os
from typing import Dict, Optional
from urllib.parse import urlencode
from fastapi import FastAPI, Request
from fastapi.responses import Response
from twilio.rest import Client
from elevenlabs import ElevenLabs
from env_utils import load_dotenv, require_env

# Load local .env if present so users can run without exporting variables manually.
load_dotenv()

_env = require_env(
    [
        "TWILIO_ACCOUNT_SID",
        "TWILIO_AUTH_TOKEN",
        "TWILIO_PHONE_NUMBER",
        "ELEVENLABS_AGENT_ID",
    ]
)

TWILIO_ACCOUNT_SID = _env["TWILIO_ACCOUNT_SID"]
TWILIO_AUTH_TOKEN = _env["TWILIO_AUTH_TOKEN"]
TWILIO_PHONE_NUMBER = _env["TWILIO_PHONE_NUMBER"]
AGENT_ID = _env["ELEVENLABS_AGENT_ID"]
WEBHOOK_BASE_URL = os.getenv("WEBHOOK_BASE_URL", "http://localhost:8000")

twilio_client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
elevenlabs = ElevenLabs()  # Uses ELEVENLABS_API_KEY from environment
app = FastAPI()

def initiate_outbound_call(
    to_number: str, call_info: Optional[Dict[str, str]] = None
) -> str:
    """
    Kick off an outbound call from your Twilio number.
    Twilio will request /twilio/outbound on this service once the call is answered.
    """
    webhook_url = f"{WEBHOOK_BASE_URL}/twilio/outbound"

    # Pass call metadata through query params so it is available to the webhook.
    if call_info:
        webhook_url = f"{webhook_url}?{urlencode(call_info)}"

    call = twilio_client.calls.create(
        from_=TWILIO_PHONE_NUMBER,
        to=to_number,
        url=webhook_url,
    )
    return call.sid

@app.post("/twilio/outbound")
async def handle_outbound_webhook(request: Request):
    """
    Twilio calls this after initiate_outbound_call is invoked.
    """
    form_data = await request.form()
    from_number = form_data.get("From")
    to_number = form_data.get("To")

    if not from_number or not to_number:
        return Response(status_code=400, content="Missing From/To in Twilio payload")

    # Any query params added when the call was initiated are exposed here for context.
    call_info = dict(request.query_params)
    client_data = {"dynamic_variables": call_info} if call_info else None

    twiml = elevenlabs.conversational_ai.twilio.register_call(
        agent_id=AGENT_ID,
        from_number=from_number,
        to_number=to_number,
        direction="outbound",
        conversation_initiation_client_data=client_data,
    )

    return Response(content=twiml, media_type="application/xml")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
