# crAPI Docker Containerization

## 1. Overview

This project uses Docker Compose to containerize and run the OWASP crAPI application locally.

The containerized deployment includes the crAPI frontend, backend services, databases, supporting services, and API gateway.

The deployment can be run locally using Docker Desktop and Docker Compose.

## 2. Containerized Services

The full Docker Compose deployment contains the following services:

* crAPI Web
* crAPI Identity
* crAPI Community
* crAPI Workshop
* crAPI Chatbot
* PostgreSQL
* MongoDB
* ChromaDB
* MailHog
* crAPI Gateway

These services communicate through the Docker Compose network.

## 3. Prerequisites

* Windows
* Docker Desktop
* Docker Engine
* Docker Compose
* Git

The application does not require Kubernetes for this local deployment.

## 4. Start the Application

From the project root, run:

```cmd
docker compose -f deploy\docker\docker-compose.yml up -d
```

Check the container status:

```cmd
docker compose -f deploy\docker\docker-compose.yml ps
```

The services should become `Up` or `Up (healthy)`.

## 5. Access the Application

The crAPI web application is available locally at:

```text
http://localhost:8888
```

The application was successfully opened and tested through a web browser.

## 6. Containerization Validation

The Docker Compose configuration was validated using:

```cmd
docker compose -f deploy\docker\docker-compose.yml config --quiet
```

The command completed without errors.

The following services were confirmed running during the final test:

* PostgreSQL — healthy
* MongoDB — healthy
* crAPI Identity — healthy
* crAPI Community — healthy
* crAPI Workshop — healthy
* crAPI Chatbot — running
* crAPI Web — running
* ChromaDB — healthy
* MailHog — healthy
* crAPI Gateway — healthy

The web application was successfully accessed through `http://localhost:8888`.

## 7. Database Initialization Issue During Testing

During the initial containerization test, the crAPI Identity service failed to start because PostgreSQL rejected its authentication attempt.

The Docker log reported a PostgreSQL password authentication failure for the `admin` database user.

The PostgreSQL container itself was healthy.

The issue was caused by previously initialized PostgreSQL persistent data containing credentials that did not match the credentials used by the current Compose configuration.

For a fresh local deployment, the Compose volumes were removed and the stack was initialized again:

```cmd
docker compose -f deploy\docker\docker-compose.yml down -v
docker compose -f deploy\docker\docker-compose.yml up -d
```

After reinitialization, all required services started successfully.

## 8. Stop the Application

To stop the containers without removing their persistent volumes:

```cmd
docker compose -f deploy\docker\docker-compose.yml down
```

To remove the containers and their local volumes for a fresh deployment:

```cmd
docker compose -f deploy\docker\docker-compose.yml down -v
```

The `-v` option should only be used when local database data does not need to be preserved.

## 9. Member 1 Contribution

The Member 1 containerization work provides:

* Docker Compose deployment configuration
* Local multi-container application deployment
* Containerized frontend and backend services
* Database containers
* Supporting service containers
* Local runtime validation
* Containerization documentation

The deployment was tested successfully on a personal Windows laptop using Docker Desktop.
