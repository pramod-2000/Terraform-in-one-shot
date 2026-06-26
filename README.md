
# PostPilot AI

<p align="center">
  AI-powered social-media planning, creation, scheduling, and publishing for modern teams.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Next.js-15-000000?logo=nextdotjs&logoColor=white" alt="Next.js 15">
  <img src="https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=black" alt="React 18">
  <img src="https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white" alt="TypeScript">
  <img src="https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/AWS-EC2%20%2B%20S3-FF9900?logo=amazonaws&logoColor=white" alt="AWS">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Docker-Implemented-2496ED?logo=docker&logoColor=white" alt="Docker implemented">
  <img src="https://img.shields.io/badge/Nginx-Maintenance%20fallback-009639?logo=nginx&logoColor=white" alt="Nginx maintenance fallback">
  <img src="https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white" alt="GitHub Actions">
  <img src="https://img.shields.io/badge/Kubernetes-Planned-326CE5?logo=kubernetes&logoColor=white" alt="Kubernetes planned">
  <img src="https://img.shields.io/badge/Terraform-Planned-7B42BC?logo=terraform&logoColor=white" alt="Terraform planned">
  <img src="https://img.shields.io/badge/Prometheus%20%2B%20Grafana-Planned-E6522C?logo=prometheus&logoColor=white" alt="Prometheus and Grafana planned">
</p>

## Overview

PostPilot AI is a production-oriented, multi-workspace social-media operations platform. It enables creators, businesses, and marketing teams to generate content with AI, plan it in a calendar, schedule posts, and publish to multiple social platforms from one dashboard.

The application keeps posts, media, and connected accounts scoped to a workspace. Scheduled publishing is handled through a cron-triggered API flow backed by PostgreSQL state transitions.

## Features

- AI-assisted social copy, image, video, Shorts, and thumbnail generation
- Content planning through month, week, and agenda calendar views
- Single-post, weekly, monthly, and bulk scheduling—up to **365 posts per request**
- Platform-specific post composition, previews, optimization, and analytics
- Workspace-aware post, media, and social-account isolation
- Scheduled publishing, publishing status tracking, retry-aware state handling, and notifications
- Credit-based billing, Razorpay subscriptions, payment verification, and top-up packs
- AWS S3-compatible media storage and PostgreSQL data persistence
- In-app maintenance mode plus Nginx static fallback during application outages

## Supported Social Platforms

| Platform | Supported content and workflow | Additional capabilities |
| --- | --- | --- |
| LinkedIn | Profile and organization publishing; text, image, video, and article/link posts | Preview, AI optimization, analytics |
| Instagram | Connected-account image and Reel/media workflows | Preview, optimizer, analytics |
| Facebook | Facebook Page text posts, images, and videos | Page and recent-post analytics |
| X / Twitter | Text and supported media publishing workflows | Preview and analytics |
| YouTube | Channel video uploads with title, description, tags, and optional thumbnail | SEO optimization and channel/video analytics |

> [!NOTE]
> Bulk scheduling is intentionally text-first for LinkedIn, Facebook, and X/Twitter. Instagram and YouTube are asset-backed individual scheduling flows. Instagram carousel scheduling is not enabled because the cron publisher does not currently support it.

## Architecture

```text
Users and teams
       │ HTTPS
       ▼
Nginx reverse proxy ───► Next.js / React application container
                                  │
          ┌───────────────────────┼────────────────────────┐
          ▼                       ▼                        ▼
 Firebase Auth + JWT         PostgreSQL             AWS S3-compatible
 session protection          posts, users,          workspace media and
                              workspaces, accounts  thumbnails
          │                       │                        │
          └───────────────────────┼────────────────────────┘
                                  ▼
      AI providers • Razorpay • Resend • Social platform APIs
                                  ▲
                                  │
       Authorized cron call: /api/cron/publish-scheduled
```

### Application stack

| Area | Technology |
| --- | --- |
| Frontend and API | Next.js 15 App Router, React 18, TypeScript, Tailwind CSS |
| Authentication | Firebase Authentication with custom JWT/session flow |
| Database | PostgreSQL 15 |
| Object storage | AWS S3-compatible storage |
| AI | OpenAI, Gemini / Google GenAI, Groq, and Hugging Face as configured |
| Payments | Razorpay |
| Email and notifications | Resend and application notification services |
| Testing | Vitest, lint, type/build validation |

## Content Scheduling and Publishing

1. A user signs in, selects a workspace, and connects a social account.
2. The user creates content manually or generates it with AI.
3. The user selects a platform, adds required media, and chooses **Publish now** or a future date and time.
4. The app saves the browser timezone and the scheduled post in PostgreSQL.
5. An external scheduler calls `POST /api/cron/publish-scheduled` with `CRON_SECRET`.
6. Due posts are selected and locked through database state transitions.
7. The platform-specific publisher submits the content and records the published or failed outcome.
8. Credits, notifications, and publish metadata are updated as applicable.

### Scheduler requirement

The application exposes the publishing cron endpoint; production still needs a reliable, authorized trigger. Use AWS EventBridge Scheduler, a secured cron service, or a future Kubernetes CronJob. Never expose the endpoint without validating `CRON_SECRET`.

## Local Development

### Prerequisites

- Node.js 20+
- npm
- PostgreSQL 15, or Docker Compose
- Environment values in `.env.local`

```bash
npm install
npm run dev
```

The app runs at [http://localhost:3000](http://localhost:3000).

### Quality checks

```bash
npm test
npm run lint
npm run typecheck
npm run check:release-env
```

## Environment Configuration

Copy `.env.example` to `.env.local` for local development or `.env` for Docker/EC2 deployment. Do not commit environment files, credentials, OAuth tokens, or database backups.

| Category | Required configuration |
| --- | --- |
| App and session | `JWT_SECRET`, `NEXT_PUBLIC_APP_URL` |
| Firebase | Client configuration and Firebase Admin credentials |
| PostgreSQL | `POSTGRES_HOST`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` |
| AWS media | `AWS_REGION`, `S3_BUCKET_NAME`, AWS credentials or an IAM role |
| AI | At least one of `OPENAI_API_KEY`, `GEMINI_API_KEY`, or `GROQ_API_KEY` |
| Scheduler | `CRON_SECRET` |
| Billing and email | Razorpay keys/webhook secret and Resend credentials |
| Maintenance | `MAINTENANCE_MODE` |

## Docker

<p>
  <img src="https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Node.js-20-339933?logo=nodedotjs&logoColor=white" alt="Node.js 20">
  <img src="https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL 15">
</p>

The repository Dockerfile is a multi-stage Node 20 Alpine build:

- **Builder:** installs dependencies and creates a standalone Next.js production build.
- **Runner:** copies the standalone build, static assets, public files, scripts, and database migrations.
- **Runtime security:** runs as a non-root `nextjs` user and serves port `3000`.

Docker Compose defines these services:

| Service | Purpose |
| --- | --- |
| `app` | PostPilot AI application, exposed as `3000:3000` |
| `postgres` | PostgreSQL 15 database with persistent `postgres_data` volume |

```bash
docker compose up --build -d
docker compose logs -f app
docker compose down
```

## AWS Deployment

<p>
  <img src="https://img.shields.io/badge/Amazon%20EC2-FF9900?logo=amazonec2&logoColor=white" alt="Amazon EC2">
  <img src="https://img.shields.io/badge/Amazon%20S3-569A31?logo=amazons3&logoColor=white" alt="Amazon S3">
  <img src="https://img.shields.io/badge/AWS-FF9900?logo=amazonaws&logoColor=white" alt="AWS">
</p>

The current production target is an AWS EC2 server running Docker. The documented server baseline is **8 GB RAM** and **30 GB disk**.

| AWS component | Role |
| --- | --- |
| EC2 | Hosts Docker, the Next.js app, PostgreSQL, and Nginx |
| EBS storage | Stores the OS, Docker layers, logs, and PostgreSQL volume; monitor free disk space |
| S3 | Stores workspace-scoped uploaded media and thumbnails |
| Security groups | Expose only 80/443 publicly; restrict SSH; do not expose PostgreSQL port 5432 |
| DNS and TLS | Route the public domain through Nginx or a load balancer and enforce HTTPS |

Recommended next AWS improvements: use an IAM instance role, AWS Secrets Manager or SSM Parameter Store, EventBridge Scheduler for cron invocation, off-host encrypted backups, CloudWatch alarms, and Amazon RDS for managed PostgreSQL.

## Nginx and Maintenance Mode

<p>
  <img src="https://img.shields.io/badge/Nginx-009639?logo=nginx&logoColor=white" alt="Nginx">
  <img src="https://img.shields.io/badge/Maintenance%20Mode-503-D97706" alt="Maintenance mode">
</p>

Nginx is the recommended host reverse proxy. It forwards requests to the application container on `127.0.0.1:3000`, terminates TLS in production, and can serve a static fallback page when the upstream application is unavailable.

### Maintenance page preview

![PostPilot AI maintenance page preview](public/images/maintenance-page-preview.png)

### Planned maintenance

Set `MAINTENANCE_MODE=true` and restart the application.

- User-facing pages are rewritten to `/maintenance`.
- Most API routes return `503` with `code: "maintenance_mode"`.
- `/api/health` and Razorpay webhooks remain reachable.

Disable maintenance by setting `MAINTENANCE_MODE=false` or removing the variable and restarting the app.

### Fallback during an application crash

If the application container is stopped, it cannot render the in-app page. Copy `public/maintenance-fallback.html` to the Nginx host, for example `/var/www/postpilot-maintenance/index.html`, and use the following pattern:

```nginx
server {
  listen 80;
  server_name your-domain.example;

  location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_intercept_errors on;
    error_page 502 503 504 /maintenance-fallback.html;
  }

  location = /maintenance-fallback.html {
    root /var/www/postpilot-maintenance;
    internal;
  }
}
```

> [!IMPORTANT]
> This repository contains a documented Nginx configuration example and a ready-made fallback HTML file. It does not currently contain a committed Nginx site-configuration file.

## CI/CD and Candidate Deployment

<p>
  <img src="https://img.shields.io/badge/GitHub%20Actions-2088FF?logo=githubactions&logoColor=white" alt="GitHub Actions">
  <img src="https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white" alt="Docker">
</p>

The GitHub Actions workflow runs on pull requests and pushes to `main`, `pre-prod`, and `dev`.

| Stage | What it does |
| --- | --- |
| Quality | Installs dependencies, formats/checks formatting, runs lint, type/build checks, PostgreSQL migrations, and tests |
| Build | Produces a clean production build after quality passes |
| Deploy | SSHes into EC2, syncs the release branch, builds the app image, validates a temporary candidate, and starts the final Compose application |

### Current candidate deployment flow

```text
Existing application: port 3000
          │
          ▼
Build a fresh app image on EC2
          │
          ▼
Start temporary candidate: postpilot-ai-new on port 3001
          │
          ▼
Run candidate health request and database migration
          │
          ▼
Stop old application and start Docker Compose app on port 3000
```

> [!WARNING]
> The workflow is a **candidate-validation deployment**, not yet a fully zero-downtime Nginx blue-green switch. It currently checks `http://localhost:3001` rather than `/api/health?full=1`, then stops the old container before starting the final one. Improve this by adding Docker health checks, using `/api/health?full=1`, and switching Nginx upstream traffic only after the final replacement is ready.

## Health, Backups, and Recovery

### Health endpoints

```text
GET /api/health
GET /api/health?full=1
```

`/api/health?full=1` includes PostgreSQL readiness and is the correct endpoint for deployment validation.

### Database backup and restore

```bash
npm run db:backup
npm run db:backup:timestamped
npm run db:restore -- --file backups/postgres/postpilot-latest.dump --yes
```

Production backups should be encrypted, stored outside the EC2 instance, and regularly restored into a separate database to prove recoverability.

## DevOps Roadmap

The following technologies are planned improvements; they are not currently implemented in this repository.

<p>
  <img src="https://img.shields.io/badge/Kubernetes-Planned-326CE5?logo=kubernetes&logoColor=white" alt="Kubernetes planned">
  <img src="https://img.shields.io/badge/Terraform-Planned-7B42BC?logo=terraform&logoColor=white" alt="Terraform planned">
  <img src="https://img.shields.io/badge/Prometheus-Planned-E6522C?logo=prometheus&logoColor=white" alt="Prometheus planned">
  <img src="https://img.shields.io/badge/Grafana-Planned-F46800?logo=grafana&logoColor=white" alt="Grafana planned">
</p>

| Tool | Planned purpose |
| --- | --- |
| Kubernetes | Run the application with Deployments, Services, Ingress, ConfigMaps, Secrets, rolling updates, and resource limits |
| Kubernetes CronJob | Securely invoke scheduled publishing or run a dedicated publish worker |
| Terraform | Define EC2, security groups, IAM, S3, DNS, monitoring, and future AWS infrastructure as code |
| Prometheus | Collect application, container, node, database, cron, and publishing metrics; create alerts |
| Grafana | Visualize uptime, latency, errors, CPU/RAM/disk, database capacity, container restarts, and publish outcomes |
| Centralized logs | Send structured application and Nginx logs to CloudWatch, Loki, or another central platform |
| RDS and queue workers | Improve database durability and support higher-volume, retry-safe scheduled publishing |

Recommended order: harden the current EC2 deployment, add monitoring and alerting, move PostgreSQL to a managed service, write Terraform, introduce Kubernetes manifests/Helm, then add scalable background workers.

## Release Checklist

1. Run `npm test`, `npm run lint`, `npm run typecheck`, and `npm run check:release-env`.
2. Confirm `GET /api/health?full=1` returns HTTP 200 in the target environment.
3. Validate `CRON_SECRET` and the external scheduler.
4. Validate OAuth connection and publish flows for every enabled social platform.
5. Verify Razorpay payments/webhooks and Resend email flows where enabled.
6. Confirm database backup completion and a rollback target before deployment.
7. Check Nginx, application, container, and database logs after deployment.

## Additional Documentation

- [Release runbook](docs/RELEASE_RUNBOOK.md)
- [Live test checklist](docs/LIVE_TEST_CHECKLIST.md)
- [Release status sheet](docs/RELEASE_STATUS_SHEET.md)
- [Maintenance mode guide](MAINTENANCE_MODE.md)
