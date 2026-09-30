# Secrets Management

This directory contains the configuration template for managing sensitive
credentials used by the crAPI Docker environment.

## Files

- `.env.example` - Safe template containing variable names and placeholders.
- `.env` - Local secret configuration. This file must never be committed.

## Setup

1. Copy `.env.example` to `.env`.
2. Replace all `CHANGE_ME` values with appropriate local values.
3. Keep the `.env` file only on the local development machine.
4. Never commit or push the real `.env` file to Git.

## Managed Secrets

The configuration provides placeholders for:

- PostgreSQL credentials
- MongoDB credentials
- JWT signing secret
- Application secret key
- SMTP credentials
- TLS keystore credentials
- API credentials
- Optional AI provider API credentials

## Security Rules

Real passwords, API keys, tokens, private keys, and other credentials must
not be stored in source code or committed to the Git repository.

The repository uses `.gitignore` rules to prevent local `.env` and other
secret files from being committed accidentally.

Docker Compose should consume these values through environment variables
rather than hardcoded credentials.