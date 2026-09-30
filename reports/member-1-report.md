# Member 1 – Containerized Architecture, Deployment and Authorization Security

## Application Architecture and Deployment

The crAPI application was deployed locally using Docker Compose as a multi-service microservice environment. The deployment was verified to contain ten services: `crapi-web`, `api.mypremiumdealership.com`, `crapi-identity`, `crapi-community`, `crapi-workshop`, `crapi-chatbot`, `postgresdb`, `mongodb`, `chromadb`, and `mailhog`. The web application was exposed on `127.0.0.1:8888`, while the chatbot and MailHog interfaces were exposed on ports 5500 and 8025 respectively. The remaining backend services and databases communicated through the internal Docker network. This separation reduced direct host exposure of backend components.

## Docker Security Hardening

The Docker Compose configuration was reviewed to identify container security risks and service dependencies. The MailHog service contained an explicit `user: root` configuration even though its image was configured to run as the non-root `mailhog` user by default. The explicit root configuration was removed and the container was recreated. Runtime verification using `docker exec mailhog id` confirmed execution as UID 1000 (`mailhog`) rather than root. Existing CPU and memory resource limits were also reviewed. Privileged mode was disabled by default, while additional capability dropping and a read-only root filesystem were not enabled because these controls were not required for the tested functionality. The application remained accessible after the hardening change.

## Container Image Scanning

Container vulnerability scanning was performed using Trivy against the `crapi/crapi-web:latest` image. The baseline scan identified 170 vulnerabilities, including 45 HIGH and 2 CRITICAL vulnerabilities. Trivy also identified a private-key file within the image. A subsequent scan was performed after the container hardening work and the results were retained as before-and-after evidence. These findings demonstrate that container security requires both configuration hardening and image-level vulnerability management.

## BOLA Vulnerability Investigation and Remediation

The authorization vulnerability investigated was Broken Object Level Authorization (BOLA), based on the crAPI vehicle-location functionality. The affected endpoint was `GET /identity/api/v2/vehicle/{carId}/location`. Before remediation, an authenticated user could provide another user's vehicle UUID and receive that vehicle's location together with the associated user's name and email. The root cause was the absence of a server-side ownership check before returning the requested vehicle information.

The vulnerability was remediated in the identity service by obtaining the authenticated user from the request token and verifying that the requested vehicle's owner ID matched the authenticated user's ID. A fixed identity-service Docker image was built and deployed. Retesting confirmed that the authenticated user could still retrieve their own vehicle information, while a request for another user's vehicle no longer returned the vehicle details. This provided functional before-and-after evidence that the authorization control prevented unauthorized object access while preserving legitimate access.

## Evidence and Reproducibility

Supporting evidence was maintained in the Member 1 evidence directory, including container deployment records, Docker hardening notes, Trivy scan outputs, source-code evidence, and before-and-after BOLA test screenshots. The implementation and evidence were committed to the `member1-container` Git branch.
