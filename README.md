# Salary management

Rails 8 **JSON API** + **React** (Vite) client for tracking employees and monthly payroll (gross pay, deductions, net pay). PostgreSQL is the primary database. Tests use **RSpec** with model and request specs.

## Stack

- **API**: Ruby 3.2 / Rails 8 (`/api/v1/...`)
- **Web**: React 19 / Vite 8 (dev server proxies `/api` → Rails)
- **DB**: PostgreSQL 16
- **DevOps**: `docker-compose.yml` (db + api + web), GitHub Actions CI (RuboCop, Brakeman, bundler-audit, **RSpec**)

## API quick reference

| Method | Path | Description |
| ------ | ---- | ----------- |
| GET | `/api/v1/employees` | List employees |
| POST | `/api/v1/employees` | Create (`employee` JSON root) |
| GET/PATCH/DELETE | `/api/v1/employees/:id` | Show / update / delete |
| GET | `/api/v1/employees/:id/payroll_entries` | List payroll rows |
| POST | `/api/v1/employees/:id/payroll_entries` | Create (`payroll_entry` root: year, month, gross, deductions). Net pay is derived server-side. |

Health check: `GET /up`

## Local development (without Docker)

Prerequisites: Ruby 3.2+, Node 20+, PostgreSQL listening locally.

```bash
bundle install
createdb salarymanagement_development
bin/rails db:migrate db:seed
bin/rails s

cd frontend
npm install
npm run dev   # http://localhost:5173 — proxies API calls to localhost:3000
```

Run tests (requires a reachable Postgres DB; set `DATABASE_URL` if needed):

```bash
DATABASE_URL=postgres://USER:PASS@127.0.0.1:5432/salarymanagement_test RAILS_ENV=test bin/rails db:test:prepare
DATABASE_URL=postgres://USER:PASS@127.0.0.1:5432/salarymanagement_test bundle exec rspec
```

## Docker Compose

```bash
docker compose up --build
```

- React: http://localhost:5173  
- API: http://localhost:3000  
- Postgres is **not** published on the host (no port clashes with local Postgres); Rails connects inside Compose via `db:5432`. To open `psql` from your machine: `docker compose exec db psql -U postgres salarymanagement_development`.

The Vite container sets `VITE_PROXY_API=http://api:3000` so browser requests to `/api` reach the Rails service. Rails allows CORS from `FRONTEND_ORIGIN` (default `http://localhost:5173`).

## Production notes

The repo includes the default Rails `Dockerfile` (Thruster, Kamal-oriented). For a static React build, run `npm run build` in `frontend/` and serve `frontend/dist` behind any CDN or reverse proxy that also routes `/api` to the Rails app.

## Assessment / TDD

Specs live under `spec/models` and `spec/requests`. Commit history is intentionally grouped into API, frontend, and DevOps layers so reviewers can follow how the system evolved.
