import logging
import os
import traceback
from pathlib import Path
from typing import Dict, Optional
from urllib.parse import urlencode
from fastapi import FastAPI, Request
from fastapi.responses import FileResponse, JSONResponse, Response
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from twilio.rest import Client
from elevenlabs import ElevenLabs
from env_utils import load_dotenv, require_env

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

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

# Required configuration
TWILIO_ACCOUNT_SID = _env["TWILIO_ACCOUNT_SID"]
TWILIO_AUTH_TOKEN = _env["TWILIO_AUTH_TOKEN"]
TWILIO_PHONE_NUMBER = _env["TWILIO_PHONE_NUMBER"]
AGENT_ID = _env["ELEVENLABS_AGENT_ID"]
WEBHOOK_BASE_URL = os.getenv("WEBHOOK_BASE_URL", "http://localhost:8000")

# Optional: ElevenLabs webhook secret for signature verification.
# Set this in your .env if you configured HMAC signing in the ElevenLabs dashboard.
ELEVENLABS_WEBHOOK_SECRET = os.getenv("ELEVENLABS_WEBHOOK_SECRET", "")

# Initialize clients
twilio_client = Client(
    TWILIO_ACCOUNT_SID,
    TWILIO_AUTH_TOKEN,
)
elevenlabs = ElevenLabs()  # Picks up ELEVENLABS_API_KEY from environment
app = FastAPI()

# ---------------------------------------------------------------------------
# Serve the frontend dashboard
# ---------------------------------------------------------------------------
STATIC_DIR = Path(__file__).parent / "static"


@app.get("/")
async def root():
    """Serve the frontend dashboard."""
    return FileResponse(STATIC_DIR / "index.html")


app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")

# ---------------------------------------------------------------------------
# In-memory store for recent call results (replace with a DB in production)
# ---------------------------------------------------------------------------
call_results: Dict[str, dict] = {}


class OutboundCallRequest(BaseModel):
    to: str  # E.164 phone number, e.g. "+1XXXXXXXXXX"
    info: Optional[Dict[str, str]] = None  # optional context passed to the agent


def initiate_outbound_call(
    to_number: str, call_info: Optional[Dict[str, str]] = None
) -> str:
    """
    Kick off an outbound call from your Twilio number. Twilio will request
    /twilio/outbound on this service once the call is answered.
    """
    webhook_url = f"{WEBHOOK_BASE_URL}/twilio/outbound"
    if call_info:
        webhook_url = f"{webhook_url}?{urlencode(call_info)}"

    call = twilio_client.calls.create(
        from_=TWILIO_PHONE_NUMBER,
        to=to_number,
        url=webhook_url,
    )
    return call.sid


# ---------------------------------------------------------------------------
# Twilio voice webhooks
# ---------------------------------------------------------------------------

@app.post("/twilio/inbound")
async def handle_inbound_call(request: Request):
    """
    Twilio voice webhook for inbound calls; returns TwiML from ElevenLabs.
    """
    form_data = await request.form()
    from_number = form_data.get("From")
    to_number = form_data.get("To")
    logger.info(f"[INBOUND] From={from_number} To={to_number}")

    if not from_number or not to_number:
        return Response(status_code=400, content="Missing From/To in Twilio payload")

    try:
        raw_response = elevenlabs.conversational_ai.twilio._raw_client.register_call(
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
        twiml = raw_response._response.text
        logger.info(f"[INBOUND] TwiML response:\n{twiml}")
        return Response(content=twiml, media_type="application/xml")
    except Exception as exc:
        logger.error(f"[INBOUND] ElevenLabs register_call failed: {exc}")
        logger.error(traceback.format_exc())
        # Return a TwiML error message so you hear it on the phone instead of generic error
        error_twiml = '<?xml version="1.0" encoding="UTF-8"?><Response><Say>An error occurred registering the call with the AI agent. Please try again later.</Say></Response>'
        return Response(content=error_twiml, media_type="application/xml")


@app.post("/twilio/outbound")
async def handle_outbound_webhook(request: Request):
    """
    Twilio calls this after initiate_outbound_call is invoked.
    """
    form_data = await request.form()
    from_number = form_data.get("From")
    to_number = form_data.get("To")
    call_info = dict(request.query_params)

    logger.info(f"[OUTBOUND] From={from_number} To={to_number} call_info={call_info}")
    logger.info(f"[OUTBOUND] Full form data: {dict(form_data)}")

    if not from_number or not to_number:
        return Response(status_code=400, content="Missing From/To in Twilio payload")

    client_data = {"dynamic_variables": call_info} if call_info else None
    logger.info(f"[OUTBOUND] Registering with ElevenLabs: agent_id={AGENT_ID}, direction=outbound, client_data={client_data}")

    try:
        raw_response = elevenlabs.conversational_ai.twilio._raw_client.register_call(
            agent_id=AGENT_ID,
            from_number=from_number,
            to_number=to_number,
            direction="outbound",
            conversation_initiation_client_data=client_data,
        )
        twiml = raw_response._response.text
        logger.info(f"[OUTBOUND] TwiML response:\n{twiml}")
        return Response(content=twiml, media_type="application/xml")
    except Exception as exc:
        logger.error(f"[OUTBOUND] ElevenLabs register_call failed: {exc}")
        logger.error(traceback.format_exc())
        # Return a TwiML error message so you hear it on the phone instead of generic error
        error_twiml = '<?xml version="1.0" encoding="UTF-8"?><Response><Say>An error occurred registering the call with the AI agent. Please try again later.</Say></Response>'
        return Response(content=error_twiml, media_type="application/xml")


# ---------------------------------------------------------------------------
# ElevenLabs post-call webhook
# ---------------------------------------------------------------------------

@app.post("/elevenlabs/webhook")
async def handle_elevenlabs_webhook(request: Request):
    """
    ElevenLabs sends a POST here after each conversation ends.

    Configure this in the ElevenLabs dashboard under your agent settings:
        Webhook URL: {WEBHOOK_BASE_URL}/elevenlabs/webhook

    The payload is a JSON object. Key fields include:
      - type: event type (e.g. "post_call_transcription", "post_call_audio", ...)
      - data.conversation_id: unique conversation identifier
      - data.agent_id: agent that handled the call
      - data.transcript: list of {role, message, ...} turns
      - data.analysis: {transcript_summary, call_successful, data_collection_results, ...}
      - data.metadata: {start_time_unix_secs, call_duration_secs, cost, ...}

    If you set ELEVENLABS_WEBHOOK_SECRET, the SDK will verify the HMAC
    signature in the `elevenlabs-signature` header before parsing.
    """
    raw_body = await request.body()
    raw_body_str = raw_body.decode("utf-8")
    sig_header = request.headers.get("elevenlabs-signature", "")

    logger.info(f"[WEBHOOK] Received ElevenLabs webhook ({len(raw_body_str)} bytes)")
    logger.debug(f"[WEBHOOK] Signature header: {sig_header}")

    # ------------------------------------------------------------------
    # Signature verification (optional but recommended in production)
    # ------------------------------------------------------------------
    if ELEVENLABS_WEBHOOK_SECRET:
        try:
            event = elevenlabs.webhooks.construct_event(
                rawBody=raw_body_str,
                sig_header=sig_header,
                secret=ELEVENLABS_WEBHOOK_SECRET,
            )
            logger.info("[WEBHOOK] Signature verified ✓")
        except Exception as exc:
            logger.error(f"[WEBHOOK] Signature verification failed: {exc}")
            return JSONResponse(status_code=401, content={"error": "Invalid signature"})
    else:
        import json
        try:
            event = json.loads(raw_body_str)
        except json.JSONDecodeError as exc:
            logger.error(f"[WEBHOOK] Failed to parse JSON body: {exc}")
            return JSONResponse(status_code=400, content={"error": "Invalid JSON"})

    # ------------------------------------------------------------------
    # Extract useful information from the webhook event
    # ------------------------------------------------------------------
    event_type = event.get("type", "unknown")
    data = event.get("data", event)  # some payloads nest under "data", some don't

    conversation_id = data.get("conversation_id", "unknown")
    agent_id = data.get("agent_id", "")

    logger.info(f"[WEBHOOK] event_type={event_type} conversation_id={conversation_id} agent_id={agent_id}")

    # Extract transcript
    transcript = data.get("transcript", [])
    if transcript:
        logger.info(f"[WEBHOOK] Transcript ({len(transcript)} turns):")
        for turn in transcript:
            role = turn.get("role", "?")
            message = turn.get("message", "")
            logger.info(f"  [{role}] {message}")

    # Extract analysis (summary, success evaluation, data collection)
    analysis = data.get("analysis", {})
    if analysis:
        summary = analysis.get("transcript_summary", "")
        call_successful = analysis.get("call_successful", "unknown")
        logger.info(f"[WEBHOOK] Call successful: {call_successful}")
        logger.info(f"[WEBHOOK] Summary: {summary}")

        # Data collection results (structured data the agent extracted)
        data_collection = analysis.get("data_collection_results", {})
        if data_collection:
            logger.info(f"[WEBHOOK] Data collected:")
            for key, result in data_collection.items():
                value = result.get("value") if isinstance(result, dict) else result
                logger.info(f"  {key}: {value}")

    # Extract metadata
    metadata = data.get("metadata", {})
    if metadata:
        duration = metadata.get("call_duration_secs", "?")
        termination = metadata.get("termination_reason", "?")
        logger.info(f"[WEBHOOK] Duration: {duration}s, Termination: {termination}")

        phone_call = metadata.get("phone_call", {})
        if phone_call:
            direction = phone_call.get("direction", "?")
            external_number = phone_call.get("external_number", "?")
            call_sid = phone_call.get("call_sid", "?")
            logger.info(f"[WEBHOOK] Phone: direction={direction} external={external_number} call_sid={call_sid}")

    # ------------------------------------------------------------------
    # Store the result (in-memory; swap with your database in production)
    # ------------------------------------------------------------------
    call_results[conversation_id] = {
        "event_type": event_type,
        "conversation_id": conversation_id,
        "agent_id": agent_id,
        "transcript": transcript,
        "analysis": analysis,
        "metadata": metadata,
        "raw_event": event,
    }
    logger.info(f"[WEBHOOK] Stored result for conversation {conversation_id} (total stored: {len(call_results)})")

    # Must return 200 so ElevenLabs knows we received it
    return JSONResponse(content={"status": "ok", "conversation_id": conversation_id})


# ---------------------------------------------------------------------------
# Fetch conversation details on-demand from ElevenLabs API
# ---------------------------------------------------------------------------

@app.get("/conversations/{conversation_id}")
async def get_conversation(conversation_id: str):
    """
    Retrieve full conversation details from ElevenLabs by conversation_id.

    This calls the ElevenLabs API directly, so it always returns the latest
    data (useful if the webhook hasn't arrived yet or you need audio URLs).
    """
    try:
        conversation = elevenlabs.conversational_ai.conversations.get(
            conversation_id=conversation_id
        )
        # Convert the pydantic model to a dict for JSON serialization
        result = {
            "conversation_id": conversation.conversation_id,
            "agent_id": conversation.agent_id,
            "agent_name": conversation.agent_name,
            "status": conversation.status,
            "has_audio": conversation.has_audio,
            "transcript": [
                {
                    "role": t.role,
                    "message": t.message,
                    "time_in_call_secs": t.time_in_call_secs,
                }
                for t in (conversation.transcript or [])
            ],
        }

        # Add analysis if available
        if conversation.analysis:
            result["analysis"] = {
                "call_successful": conversation.analysis.call_successful,
                "transcript_summary": conversation.analysis.transcript_summary,
            }
            if conversation.analysis.data_collection_results:
                result["analysis"]["data_collection_results"] = {
                    k: {"value": v.value, "rationale": v.rationale}
                    for k, v in conversation.analysis.data_collection_results.items()
                }

        # Add metadata
        if conversation.metadata:
            result["metadata"] = {
                "call_duration_secs": conversation.metadata.call_duration_secs,
                "start_time_unix_secs": conversation.metadata.start_time_unix_secs,
                "termination_reason": conversation.metadata.termination_reason,
                "cost": conversation.metadata.cost,
            }

        return JSONResponse(content=result)

    except Exception as exc:
        logger.error(f"[GET_CONVERSATION] Failed to fetch {conversation_id}: {exc}")
        logger.error(traceback.format_exc())
        return JSONResponse(
            status_code=500,
            content={"error": str(exc), "conversation_id": conversation_id},
        )


# ---------------------------------------------------------------------------
# List recently received webhook results
# ---------------------------------------------------------------------------

@app.get("/call-results")
async def list_call_results():
    """
    Return all call results received via the post-call webhook.
    Most recent first. In production, paginate and query from a database.
    """
    results = list(call_results.values())
    # Return a summary (without the full raw_event to keep it concise)
    summaries = []
    for r in reversed(results):
        summary = {
            "conversation_id": r["conversation_id"],
            "event_type": r["event_type"],
            "agent_id": r["agent_id"],
        }
        if r.get("analysis"):
            summary["call_successful"] = r["analysis"].get("call_successful", "unknown")
            summary["transcript_summary"] = r["analysis"].get("transcript_summary", "")
            data_collection = r["analysis"].get("data_collection_results", {})
            if data_collection:
                summary["data_collected"] = {
                    k: (v.get("value") if isinstance(v, dict) else v)
                    for k, v in data_collection.items()
                }
        if r.get("metadata"):
            summary["call_duration_secs"] = r["metadata"].get("call_duration_secs")
            summary["termination_reason"] = r["metadata"].get("termination_reason")
        summary["transcript_turns"] = len(r.get("transcript", []))
        summaries.append(summary)

    return JSONResponse(content={"count": len(summaries), "results": summaries})


@app.get("/call-results/{conversation_id}")
async def get_call_result(conversation_id: str):
    """
    Return the full stored webhook result for a specific conversation.
    """
    result = call_results.get(conversation_id)
    if not result:
        return JSONResponse(
            status_code=404,
            content={"error": "No webhook result found for this conversation_id", "conversation_id": conversation_id},
        )
    return JSONResponse(content=result)


# ---------------------------------------------------------------------------
# Trigger outbound call via REST API
# ---------------------------------------------------------------------------

@app.post("/call/outbound")
async def api_outbound_call(body: OutboundCallRequest):
    """
    Trigger an outbound call via the API.

    POST /call/outbound
    {
        "to": "+1XXXXXXXXXX",
        "info": {"customer_id": "123", "reason": "renewal"}
    }
    """
    try:
        sid = initiate_outbound_call(body.to, body.info)
        return JSONResponse(content={"status": "ok", "call_sid": sid})
    except Exception as exc:
        return JSONResponse(status_code=500, content={"status": "error", "detail": str(exc)})


@app.api_route("/request/call", methods=["GET", "POST"])
async def request_call(request: Request):
    """
    Simple endpoint to trigger an outbound call via query params.

    Works with both GET and POST so you can call it from a browser or curl easily.

    Examples:
        GET  /request/call?mobile=+27677789046&customer_id=Jane+Doe&booking_time=15:00&booking_date=friday&num_people=5
        POST /request/call?mobile=+27677789046&customer_id=Jane+Doe&booking_time=15:00

    The 'mobile' param is required (the number to call).
    All other query params are passed to the ElevenLabs agent as dynamic_variables.
    """
    params = dict(request.query_params)

    # Also merge form body params for POST requests
    if request.method == "POST":
        try:
            form_data = await request.form()
            for key, value in form_data.items():
                if key not in params:
                    params[key] = value
        except Exception:
            pass

    # Extract the phone number (accept 'mobile', 'to', or 'phone')
    mobile = params.pop("mobile", None) or params.pop("to", None) or params.pop("phone", None)

    if not mobile:
        return JSONResponse(
            status_code=400,
            content={
                "status": "error",
                "detail": "Missing required param: 'mobile' (E.164 phone number, e.g. +27677789046)",
                "example": "/request/call?mobile=+27677789046&customer_id=Jane+Doe&booking_time=15:00",
            },
        )

    # Everything else becomes call_info (dynamic variables for the agent)
    call_info = params if params else None

    logger.info(f"[REQUEST_CALL] mobile={mobile} info={call_info}")

    try:
        sid = initiate_outbound_call(mobile, call_info)
        return JSONResponse(content={
            "status": "ok",
            "call_sid": sid,
            "mobile": mobile,
            "info": call_info,
        })
    except Exception as exc:
        logger.error(f"[REQUEST_CALL] Failed: {exc}")
        logger.error(traceback.format_exc())
        return JSONResponse(status_code=500, content={"status": "error", "detail": str(exc)})


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
