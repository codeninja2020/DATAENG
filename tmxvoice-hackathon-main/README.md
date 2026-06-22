# TenMAIDxVoice

FastAPI service that bridges Twilio voice calls with an ElevenLabs Conversational AI agent. Handles both inbound and outbound calls, returns TwiML to connect audio via WebSocket, receives post-call results via webhook, and exposes a dashboard UI and REST API for triggering calls and viewing results.

## Live deployment

Hosted on Railway: `https://tmxvoice-hackathon-production.up.railway.app`

- **Dashboard UI** → `GET /`
- **API docs** → `GET /docs`

---

## Prerequisites

- [uv](https://docs.astral.sh/uv/) — Python package manager (`brew install uv` on macOS)
- Python 3.9+ (managed automatically by uv via `.python-version`)
- Twilio account with a voice-enabled phone number
- ElevenLabs account with a Conversational AI agent configured for μ-law 8000 Hz input/output
- A publicly reachable URL for webhooks — deploy to Railway (see below) or use a tunnel tool for local dev

---

## Install

```bash
uv sync
```

This reads `pyproject.toml`, creates a virtual environment in `.venv`, and installs all dependencies. No need to manually `pip install` anything.

---

## Environment

Copy the example below into a `.env` file in the project root. The app auto-loads `.env` on startup.

```
ELEVENLABS_API_KEY=...
ELEVENLABS_AGENT_ID=...

TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=...

WEBHOOK_BASE_URL=https://your-public-host   # no trailing slash; defaults to http://localhost:8000
PORT=8000                                    # optional, defaults to 8000

# Optional: HMAC secret for verifying ElevenLabs webhook signatures.
# Set this if you enabled HMAC signing in the ElevenLabs dashboard.
ELEVENLABS_WEBHOOK_SECRET=...
```

> **Railway:** environment variables are set directly in the Railway dashboard or via `railway variables set KEY=value`. The `.env` file is only used for local development.

---

## Run the server

```bash
uv run uvicorn makecall:app --host 0.0.0.0 --port 8000 --reload
```

Or run the entry point directly:

```bash
uv run makecall.py
```

The server listens on `PORT` (default `8000`).

---

## Endpoints

### Dashboard
| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | Frontend dashboard — make calls and view results |

### Trigger a call
| Method | Path | Description |
|--------|------|-------------|
| `GET\|POST` | `/request/call` | Start an outbound call via query params (simplest) |
| `POST` | `/call/outbound` | Start an outbound call via JSON body |

### Twilio voice webhooks
| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/twilio/inbound` | Twilio calls this when someone calls your number |
| `POST` | `/twilio/outbound` | Twilio calls this when an outbound call is answered |

### ElevenLabs webhook
| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/elevenlabs/webhook` | ElevenLabs posts call results here after each conversation ends |

### Call results
| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/call-results` | List all received call results (most recent first) |
| `GET` | `/call-results/{conversation_id}` | Full webhook payload for a specific conversation |
| `GET` | `/conversations/{conversation_id}` | Fetch conversation details live from the ElevenLabs API |

---

## Making calls

### From the dashboard

Visit `https://tmxvoice-hackathon-production.up.railway.app/` and fill in the form. Fields map directly to `dynamic_variables` passed to the ElevenLabs agent.

### Via `/request/call` (simplest)

Works with GET or POST — pass everything as query params:

```bash
curl "https://your-public-host/request/call?mobile=+XXXXXXXXXXX&customer_id=John+Doe&booking_time=15:00+pm&booking_date=friday&num_people=5"
```

The `mobile` param is required (also accepts `to` or `phone`). All other params are forwarded to the agent as `dynamic_variables`.

**Response:**
```json
{
  "status": "ok",
  "call_sid": "CA...",
  "mobile": "+XXXXXXXXXXX",
  "info": {"customer_id": "John Doe", "booking_time": "15:00 pm", "booking_date": "friday", "num_people": "5"}
}
```

| CLI (`start_call.py`) | `/request/call` query param |
|---|---|
| `--to +XXXXXXXXXXX` | `mobile=+XXXXXXXXXXX` |
| `--info customer_id="John Doe"` | `customer_id=John+Doe` |
| `--info booking_time="15:00 pm"` | `booking_time=15:00+pm` |
| `--info booking_date="friday"` | `booking_date=friday` |
| `--info num_people="5"` | `num_people=5` |

### Via `start_call.py`

```bash
uv run start_call.py --to +XXXXXXXXXXX --info customer_id="John Doe" --info booking_time="15:00 pm" --info booking_date="friday" --info num_people="5"
```

`--info` can be repeated for any key/value pair. All values reach ElevenLabs as `dynamic_variables`.

### Via JSON API

```bash
curl -X POST https://your-public-host/call/outbound \
  -H "Content-Type: application/json" \
  -d '{"to": "+XXXXXXXXXXX", "info": {"customer_id": "John Doe", "reason": "dinner booking"}}'
```

---

## Configure Twilio (inbound calls)

1. Deploy to Railway so the server has a public HTTPS URL (see [Deploying to Railway](#deploying-to-railway) below).
2. In the Twilio Console, set your number's **Voice webhook** (HTTP POST) to:
   ```
   https://tmxvoice-hackathon-production.up.railway.app/twilio/inbound
   ```
3. When someone calls your Twilio number, the service registers the call with ElevenLabs and returns TwiML to Twilio to connect the audio stream.

---

## Configure ElevenLabs post-call webhook

After each call ends, ElevenLabs POSTs the conversation results (transcript, analysis, collected data) to your server.

### Steps

1. Go to the [ElevenLabs dashboard](https://elevenlabs.io/app/conversational-ai).
2. Select your agent → **Settings** → **Webhooks**.
3. Under **Post-call webhook**, set the URL to:
   ```
   https://tmxvoice-hackathon-production.up.railway.app/elevenlabs/webhook
   ```
4. Select which events to send:
   - **transcript** — full conversation transcript and analysis
   - **audio** — audio recording of the call
   - **call_initiation_failure** — fires when a call fails to start
5. (Recommended) Enable **HMAC signing** and copy the secret into your `.env` as `ELEVENLABS_WEBHOOK_SECRET`.

### Webhook payload structure

```json
{
  "type": "post_call_transcription",
  "data": {
    "conversation_id": "conv_abc123",
    "agent_id": "agent_xyz",
    "transcript": [
      {"role": "agent", "message": "Hello, how can I help you?", "time_in_call_secs": 0},
      {"role": "user",  "message": "I'd like to book a table.",  "time_in_call_secs": 3}
    ],
    "analysis": {
      "call_successful": "success",
      "transcript_summary": "Customer booked a table for 2 at 7pm.",
      "data_collection_results": {
        "party_size": {"value": "2",     "rationale": "Customer said a table for 2."},
        "time":       {"value": "19:00", "rationale": "Customer requested 7pm."}
      }
    },
    "metadata": {
      "start_time_unix_secs": 1700000000,
      "call_duration_secs": 45,
      "termination_reason": "agent_goodbye",
      "phone_call": {
        "type": "twilio",
        "direction": "inbound",
        "external_number": "+XXXXXXXXXXX",
        "call_sid": "CA..."
      }
    }
  }
}
```

### Signature verification

If `ELEVENLABS_WEBHOOK_SECRET` is set, the server verifies the `elevenlabs-signature` header using HMAC-SHA256 before processing the payload. Invalid or missing signatures return `401 Unauthorized`.

---

## Querying call results

### List all results
```bash
curl https://tmxvoice-hackathon-production.up.railway.app/call-results
```

### Get a specific result
```bash
curl https://tmxvoice-hackathon-production.up.railway.app/call-results/conv_abc123
```

### Fetch live from ElevenLabs API
```bash
curl https://tmxvoice-hackathon-production.up.railway.app/conversations/conv_abc123
```

This hits the ElevenLabs API directly and always returns the latest data (useful if the webhook hasn't arrived yet).

---

## Deploying to Railway

The project is deployed manually via the Railway CLI (Railway is **not** connected to the GitHub repo for auto-deploy).

```bash
# First time setup
railway login
railway link

# Deploy current local code
railway up -d

# Set / update environment variables
railway variables set KEY=value

# View all current variables
railway variables

# Stream logs
railway logs
```

> The `Procfile` tells Railway how to start the server:
> ```
> web: uvicorn makecall:app --host 0.0.0.0 --port $PORT
> ```

---

## Project structure

```
tmxvoice-hackathon/
├── makecall.py          # Main server — all endpoints, inbound + outbound + webhook + UI
├── makecall_inbound.py  # Standalone inbound-only server (for reference)
├── makecall_outbound.py # Standalone outbound-only server (for reference)
├── start_call.py        # CLI script to trigger an outbound call
├── env_utils.py         # Lightweight .env loader and env var validator
├── static/
│   └── index.html       # Frontend dashboard (served at /)
├── pyproject.toml       # Dependencies and project metadata (used by uv)
├── uv.lock              # Locked dependency versions
├── .python-version      # Python version pin (read by uv)
├── Procfile             # Process definition (tells Railway how to start the server)
└── .env                 # Local environment variables (not committed)
```

---

## Architecture

```
                          ┌──────────────────────────┐
   Caller dials in ───►   │          Twilio          │
   or outbound call       │      (Voice webhook)     │
                          └──────┬───────────────────┘
                                 │ POST /twilio/inbound
                                 │ POST /twilio/outbound
                                 ▼
                          ┌──────────────────────────┐
                          │     TenMAIDxVoice app    │
                          │       (makecall.py)      │
                          └──────┬───────────────────┘
                                 │ register_call()
                                 ▼
                          ┌──────────────────────────┐
                          │      ElevenLabs API      │
                          │    (Conversational AI)   │
                          └──────┬───────────────────┘
                                 │ TwiML → WebSocket audio stream
                                 ▼
                          ┌──────────────────────────┐
                          │  Twilio ◄──► ElevenLabs  │
                          │    (live audio call)     │
                          └──────┬───────────────────┘
                                 │ Call ends
                                 ▼
                          ┌──────────────────────────┐
                          │        ElevenLabs        │
                          │ POST /elevenlabs/webhook │
                          └──────┬───────────────────┘
                                 │ transcript + analysis + data
                                 ▼
                          ┌──────────────────────────┐
                          │    App stores result     │
                          │     (query via API)      │
                          │  (view in ui dashboard)  │
                          └──────────────────────────┘
```

---

## Notes and limitations

- **In-memory storage:** Call results are stored in a Python dict and will be lost on server restart. For production, replace the `call_results` dict in `makecall.py` with a persistent database (PostgreSQL, MongoDB, Redis, etc.).
- **No call transfers:** The Twilio `register_call` pattern does not support call transfers.
- **ElevenLabs dashboard:** Calls registered via `register_call()` do not appear in the ElevenLabs dashboard — manage routing in Twilio.
- **HTTPS required:** Both Twilio and ElevenLabs require publicly reachable HTTPS endpoints — Railway provides this automatically.
- **`makecall_inbound.py` / `makecall_outbound.py`:** Standalone single-purpose versions of the server kept for reference. The main entry point is `makecall.py` which handles everything.
