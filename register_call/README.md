# Register Twilio calls with ElevenLabs

FastAPI service that registers inbound and outbound Twilio calls with an ElevenLabs Conversational Agent and returns TwiML for Twilio to connect via WebSocket.

## Prerequisites
- Python 3.9+
- Twilio account with a voice-enabled phone number
- ElevenLabs account and agent configured for μ-law 8000 Hz input/output
- Publicly reachable URL for webhooks (e.g., ngrok) for Twilio to call

## Install
```bash
pip install -r requirements.txt
```

## Environment
Set the following (you can export them or place them in a `.env` file; the apps auto-load `.env` if present):
```
ELEVENLABS_API_KEY=...
ELEVENLABS_AGENT_ID=...
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=...
WEBHOOK_BASE_URL=https://your-public-host  # defaults to http://localhost:8000
PORT=8000  # optional
```

## Run the server (combined)
```bash
python makecall.py
```
Server listens on `PORT` or 8000 and exposes:
- `POST /twilio/inbound`: Twilio voice webhook for inbound calls
- `POST /twilio/outbound`: Twilio voice webhook used after initiating outbound calls

## Run inbound-only
```bash
python makecall_inbound.py
```
Use when you only need to handle inbound calls. Webhook: `POST /twilio/inbound`.

## Run outbound-only
```bash
python makecall_outbound.py
```
Use when you only need outbound calls. Webhook: `POST /twilio/outbound`. Helper to start a call:
```python
from makecall_outbound import initiate_outbound_call
sid = initiate_outbound_call(
    "+1XXXXXXXXXX",  # number to dial
    {"customer_id": "123", "reason": "renewal"},  # optional call context
)
```

## Configure Twilio (inbound)
1. Start the server and expose it (e.g., `ngrok http 8000`).
2. In Twilio Console, set your number's Voice webhook (POST) to `WEBHOOK_BASE_URL/twilio/inbound`.
3. Call the number; the service registers with ElevenLabs and returns TwiML to Twilio.

## Outbound flow
Initiate a call programmatically; Twilio will hit `/twilio/outbound` when the call is answered.
```python
from makecall import initiate_outbound_call
sid = initiate_outbound_call(
    "+1XXXXXXXXXX",  # number to dial
    {"customer_id": "123", "reason": "renewal"},  # optional call context
)
print("Call SID:", sid)
```
Ensure `WEBHOOK_BASE_URL` is publicly reachable (ngrok or your host) so Twilio can call back.

Outbound call context you provide is passed as query params to `/twilio/outbound` and forwarded to ElevenLabs as `dynamic_variables` in `conversation_initiation_client_data`.

### Start an outbound call from the CLI
Load your `.env`, start the server, then run:
```bash
python start_call.py --to +1XXXXXXXXXX --info customer_id=123 --info reason=renewal
```
`--info` can be repeated to add any key/value context. That context reaches ElevenLabs as `dynamic_variables`.

## Personalization
`/twilio/inbound` demonstrates passing dynamic variables:
```python
conversation_initiation_client_data={
    "dynamic_variables": {
        "caller_number": from_number,
    }
}
```
Adjust payload per call to provide context or overrides for the agent.

## Notes and limitations
- Call transfers are not supported with this register-call pattern.
- Numbers connected this way do not appear in the ElevenLabs dashboard; you manage routing in Twilio.
- You must handle HTTPS/public exposure for Twilio webhooks; localhost alone will not work.
