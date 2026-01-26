# Greenlight API

A JSON API for managing movie information, built with Go.

## Features

- RESTful API design with versioned endpoints (`/v1/...`)
- JSON request/response handling
- Input validation
- Custom error responses
- Panic recovery middleware
- Structured logging with `slog`
- PostgreSQL database support

## Tech Stack

- **Language:** Go 1.24+
- **Router:** [httprouter](https://github.com/julienschmidt/httprouter)
- **Database:** PostgreSQL (using [lib/pq](https://github.com/lib/pq))

## Project Structure

```
greenlight/
├── cmd/
│   └── api/           # Application entrypoint and HTTP handlers
├── internal/
│   ├── data/          # Database models and business logic
│   └── validator/     # Input validation utilities
├── migrations/        # Database migration files
├── bin/               # Compiled binaries
└── remote/            # Remote server configuration
```

## Getting Started

### Prerequisites

- Go 1.24 or later
- PostgreSQL

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/shaheerkj/greenlight.git
   cd greenlight
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

3. Run the application:
   ```bash
   go run ./cmd/api
   ```

   Or build and run:
   ```bash
   go build -o ./bin/api ./cmd/api
   ./bin/api
   ```

### Command-line Flags

| Flag | Default | Description |
|------|---------|-------------|
| `-port` | `4000` | API server port |
| `-env` | `development` | Environment (development\|staging\|production) |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/v1/healthcheck` | Show application health and version info |
| `POST` | `/v1/movies` | Create a new movie |
| `GET` | `/v1/movies/:id` | Show details of a specific movie |

### Example Requests

**Create a movie:**
```bash
curl -X POST http://localhost:4000/v1/movies \
  -H "Content-Type: application/json" \
  -d '{"title":"Moana","year":2016,"runtime":107,"genres":["animation","adventure"]}'
```

**Get a movie:**
```bash
curl http://localhost:4000/v1/movies/1
```

**Health check:**
```bash
curl http://localhost:4000/v1/healthcheck
```

## Movie Validation Rules

| Field | Rules |
|-------|-------|
| `title` | Required, max 500 characters |
| `year` | Required, between 1888 and current year |
| `runtime` | Required, positive integer (minutes) |
| `genres` | Required, 1-5 unique values |

## Error Responses

All errors are returned as JSON:

```json
{
  "error": "Resource not found"
}
```

Validation errors include field-specific messages:

```json
{
  "error": {
    "title": "must be provided",
    "year": "must be greater than 1888"
  }
}
```

## License

MIT
