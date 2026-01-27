# Greenlight API

A JSON API for managing movie information, built with Go.

## Features

- RESTful API design with versioned endpoints (`/v1/...`)
- Full CRUD operations for movies
- Filtering, pagination, and sorting support
- JSON request/response handling
- Input validation with database constraints
- Optimistic concurrency control (version-based updates)
- Custom error responses
- Panic recovery middleware
- Structured logging with `slog`
- PostgreSQL database with connection pooling
- Database migrations

## Tech Stack

- **Language:** Go 1.24+
- **Router:** [httprouter](https://github.com/julienschmidt/httprouter)
- **Database:** PostgreSQL (using [lib/pq](https://github.com/lib/pq))
- **Migrations:** [golang-migrate](https://github.com/golang-migrate/migrate)
- **Environment:** [godotenv](https://github.com/joho/godotenv)

## Project Structure

```
greenlight/
├── cmd/
│   └── api/           # Application entrypoint and HTTP handlers
│       ├── main.go        # Entry point, config, DB connection
│       ├── routes.go      # Route definitions
│       ├── handlers.go    # HTTP handlers
│       ├── helpers.go     # Helper functions
│       ├── errors.go      # Error response handlers
│       └── middleware.go  # HTTP middleware
├── internal/
│   ├── data/          # Database models and business logic
│   │   ├── movies.go      # Movie model and CRUD operations
│   │   └── runtime.go     # Custom runtime type
│   └── validator/     # Input validation utilities
├── migrations/        # Database migration files
├── bin/               # Compiled binaries
└── remote/            # Remote server configuration
```

## Getting Started

### Prerequisites

- Go 1.24 or later
- PostgreSQL
- [golang-migrate](https://github.com/golang-migrate/migrate) CLI

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

3. Create the database and user:
   ```sql
   CREATE DATABASE greenlight;
   CREATE USER greenlight WITH PASSWORD 'your_password';
   GRANT ALL ON SCHEMA public TO greenlight;
   ```

4. Run database migrations:
   ```bash
   # Set your DSN
   $GREENLIGHT_DB_DSN="postgres://greenlight:password@localhost:5432/greenlight?sslmode=disable"
   
   # Run migrations
   migrate -path migrations -database $GREENLIGHT_DB_DSN up
   ```

5. Run the application:
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
| `-db-dsn` | from `.env` | PostgreSQL DSN |
| `-db-max-open-conns` | `25` | Max open database connections |
| `-db-max-idle-conns` | `25` | Max idle database connections |
| `-db-max-idle-time` | `15m` | Max connection idle time |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/v1/healthcheck` | Show application health and version info |
| `POST` | `/v1/movies` | Create a new movie |
| `GET` | `/v1/movies` | List all movies (with filtering, pagination, sorting) |
| `GET` | `/v1/movies/:id` | Show details of a specific movie |
| `PATCH` | `/v1/movies/:id` | Update a specific movie (partial update) |
| `DELETE` | `/v1/movies/:id` | Delete a specific movie |

### Query Parameters for Listing Movies

| Parameter | Default | Description |
|-----------|---------|-------------|
| `title` | `""` | Filter by title (case-insensitive) |
| `genres` | `[]` | Filter by genres (comma-separated) |
| `page` | `1` | Page number |
| `page_size` | `20` | Results per page |
| `sort` | `id` | Sort field |

### Example Requests

**Create a movie:**
```bash
curl -X POST http://localhost:4000/v1/movies \
  -H "Content-Type: application/json" \
  -d '{"title":"Moana","year":2016,"runtime":"107 mins","genres":["animation","adventure"]}'
```

**Get a movie:**
```bash
curl http://localhost:4000/v1/movies/1
```

**Update a movie (partial):**
```bash
curl -X PATCH http://localhost:4000/v1/movies/1 \
  -H "Content-Type: application/json" \
  -d '{"year":2017}'
```

**Delete a movie:**
```bash
curl -X DELETE http://localhost:4000/v1/movies/1
```

**List movies with filters:**
```bash
curl "http://localhost:4000/v1/movies?title=moana&genres=animation&page=1&page_size=10&sort=year"
```

**Health check:**
```bash
curl http://localhost:4000/v1/healthcheck
```

## Database Migrations

```bash
# Apply all pending migrations
migrate -path migrations -database $GREENLIGHT_DB_DSN up

# Rollback the last migration
migrate -path migrations -database $GREENLIGHT_DB_DSN down 1

# Check current migration version
migrate -path migrations -database $GREENLIGHT_DB_DSN version

# Force a specific version (use with caution)
migrate -path migrations -database $GREENLIGHT_DB_DSN force VERSION
```

## Movie Validation Rules

| Field | Rules |
|-------|-------|
| `title` | Required, max 500 characters |
| `year` | Required, between 1888 and current year |
| `runtime` | Required, positive integer (minutes) |
| `genres` | Required, 1-5 unique values |

### Database Constraints

The database enforces additional constraints:
- `runtime >= 0`
- `year BETWEEN 1888 AND current year`
- `genres` array length between 1 and 5

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