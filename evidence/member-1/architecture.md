# crAPI Containerized Architecture

## Deployed Services

The crAPI deployment was verified using Docker Compose. The deployment contains the following services:

1. crapi-web - Web frontend
2. api.mypremiumdealership.com - API gateway
3. crapi-identity - Identity and authentication service
4. crapi-community - Community service
5. crapi-workshop - Workshop service
6. crapi-chatbot - Chatbot service
7. postgresdb - PostgreSQL database
8. mongodb - MongoDB database
9. chromadb - Chroma vector database
10. mailhog - Email testing service

## Host-Exposed Ports

- crapi-web: 127.0.0.1:8888 -> container port 80
- crapi-chatbot: 127.0.0.1:5500 -> container port 5500
- mailhog: 127.0.0.1:8025 -> container port 8025

The remaining application services and databases communicate internally through the Docker network.

## Main Service Relationships

- crapi-web communicates with the identity, community, workshop and chatbot services.
- crapi-identity uses PostgreSQL and MongoDB and communicates with MailHog.
- crapi-community uses PostgreSQL and MongoDB and communicates with the identity service.
- crapi-workshop communicates with the community and identity services and uses PostgreSQL and MongoDB.
- crapi-chatbot communicates with ChromaDB, MongoDB, identity and the web service.
- MailHog provides email testing functionality.

## Trust Boundaries

The architecture contains the following main trust boundaries:

1. User/browser to the containerized application.
2. Frontend/API layer to backend microservices.
3. Backend services to database and supporting data services.
4. CI/CD and container registry to the deployment environment.

## Security Considerations

The containerized deployment exposes only the required host ports. Backend services and databases are not directly published to the host. Authentication and object-level authorization are enforced by the application services.
