import os
from fastapi import FastAPI, Request
from fastapi.responses import Response
from elevenlabs import ElevenLabs
from env_utils import load_dotenv, require_env

# Load local .env if present so users can run without exporting variables manually.
load_dotenv()

AGENT_ID = require_env(["ELEVENLABS_AGENT_ID"])["ELEVENLABS_AGENT_ID"]
elevenlabs = ElevenLabs()  # Uses ELEVENLABS_API_KEY from environment
app = FastAPI()


@app.post("/twilio/inbound")
async def handle_inbound_call(request: Request):
    """
    Twilio voice webhook for inbound calls; returns TwiML from ElevenLabs.
    """
    form_data = await request.form()
    from_number = form_data.get("From")
    to_number = form_data.get("To")

    if not from_number or not to_number:
        return Response(status_code=400, content="Missing From/To in Twilio payload")

    twiml = elevenlabs.conversational_ai.twilio.register_call(
        agent_id=AGENT_ID,
        from_number=from_number,
        to_number=to_number,
        direction="inbound",
        conversation_initiation_client_data={
            "dynamic_variables": {
                "caller_number": from_number,
            }
        },
    )

    return Response(content=twiml, media_type="application/xml")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
