from twilio.rest import Client
import os
from fastapi import Request
from fastapi.responses import Response
from elevenlabs import ElevenLabs

# Initialize clients
twilio_client = Client(
    os.getenv("TWILIO_ACCOUNT_SID"),
    os.getenv("TWILIO_AUTH_TOKEN")
)
elevenlabs = ElevenLabs()
AGENT_ID = os.getenv("ELEVENLABS_AGENT_ID")

def initiate_outbound_call(to_number: str):
    call = twilio_client.calls.create(
        from_=os.getenv("TWILIO_PHONE_NUMBER"),
        to=to_number,
        url="https://your-server.com/twilio/outbound"
    )
    return call.sid

@app.post("/twilio/outbound")
async def handle_outbound_webhook(request: Request):
    form_data = await request.form()
    from_number = form_data.get("From")
    to_number = form_data.get("To")

    twiml = elevenlabs.conversational_ai.twilio.register_call(
        agent_id=AGENT_ID,
        from_number=from_number,
        to_number=to_number,
        direction="outbound",
    )

    return Response(content=twiml, media_type="application/xml")
