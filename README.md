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
- **Docker support** with multi-stage builds (~20MB image)
- **Docker Compose** for full-stack deployment

## Tech Stack

- **Language:** Go 1.24+
- **Router:** [httprouter](https://github.com/julienschmidt/httprouter)
- **Database:** PostgreSQL 16 (using [lib/pq](https://github.com/lib/pq))
- **Migrations:** [golang-migrate](https://github.com/golang-migrate/migrate)
- **Environment:** [godotenv](https://github.com/joho/godotenv)
- **Containerization:** Docker, Docker Compose

## Project Structure

```
greenlight/
├── cmd/
│   └── api/               # Application entrypoint and HTTP handlers
│       ├── main.go            # Entry point, config, DB connection
│       ├── routes.go          # Route definitions
│       ├── movies.go          # Movie handlers
│       ├── helpers.go         # Helper functions
│       ├── errors.go          # Error response handlers
│       └── middleware.go      # HTTP middleware
├── internal/
│   ├── data/              # Database models and business logic
│   │   ├── models.go          # Model registry
│   │   ├── movies.go          # Movie model and CRUD operations
│   │   └── runtime.go         # Custom runtime type
│   └── validator/         # Input validation utilities
├── migrations/            # Database migration files
├── bin/                   # Compiled binaries
├── Dockerfile             # Multi-stage Docker build
├── docker-compose.yml     # Full-stack deployment
├── .env.example           # Environment template
└── remote/                # Remote server configuration
```

## Getting Started

### Option 1: Docker Compose (Recommended)

The easiest way to run the entire stack:

1. Clone the repository:
   ```bash
   git clone https://github.com/shaheerkj/greenlight.git
   cd greenlight
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

3. Start the stack:
   ```bash
   docker-compose up
   ```

   This will:
   - Start PostgreSQL
   - Run database migrations automatically
   - Start the API server on port 4000

4. Access the API:
   ```bash
   curl http://localhost:4000/v1/healthcheck
   ```

### Option 2: Local Development

#### Prerequisites

- Go 1.24 or later
- PostgreSQL
- [golang-migrate](https://github.com/golang-migrate/migrate) CLI

#### Installation

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
   migrate -path migrations -database "postgres://greenlight:password@localhost:5432/greenlight?sslmode=disable" up
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

## Docker

### Build the Image

```bash
docker build -t greenlight .
```

### Run Standalone (with external PostgreSQL)

```bash
docker run -p 4000:4000 \
  -e DB_USERNAME=greenlight \
  -e DB_PASSWORD=your_password \
  -e DB_NAME=greenlight \
  -e DB_HOST=host.docker.internal \
  greenlight
```

### Docker Compose Commands

```bash
# Start all services
docker-compose up

# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f api

# Stop services
docker-compose down

# Stop and remove volumes (deletes database data)
docker-compose down -v

# Rebuild after code changes
docker-compose up --build
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_USERNAME` | Database username | `greenlight` |
| `DB_PASSWORD` | Database password | `your_password` |
| `DB_NAME` | Database name | `greenlight` |
| `DB_HOST` | Database host | `localhost` or `db` (in Docker) |

## Command-line Flags

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

### Using Docker

Migrations run automatically with `docker-compose up`.

### Manual Migration Commands

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