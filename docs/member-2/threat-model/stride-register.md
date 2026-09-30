OWASP crAPI STRIDE Threat Register

 
## Method

 
The STRIDE model was applied to assets, processes, data stores,

data flows and trust boundaries identified in the crAPI Data Flow Diagram.

 
The categories are:

 
- S: Spoofing

- T: Tampering

- R: Repudiation

- I: Information Disclosure

- D: Denial of Service

- E: Elevation of Privilege

 
---

 
## T1: Credential impersonation

 
- STRIDE category: Spoofing

- Asset: A1 User credentials

- Component: crapi-identity

- Data flow: DF2 User login

- Trust boundary: TB1 and TB2

- Threat scenario: An unauthorized party attempts to authenticate as another user using compromised or guessed credentials.

- Likelihood: 3

- Impact: 4

- Risk score: 12

- Rating: High

- Existing control: Authentication mechanism

- Recommended controls: Strong password controls, secure password storage, rate limiting, failed-login monitoring and secure account recovery.

- Validation method: Source review, authentication testing and log review.

- Owner: Member 2

- Status: Open for assessment

 
---

 
## T2: Authentication token misuse

 
- STRIDE category: Spoofing

- Asset: A2 Authentication tokens

- Component: Identity and backend services

- Data flow: DF3 and DF4

- Trust boundary: TB1 and TB2

- Threat scenario: A stolen, expired, incorrectly signed or insufficiently validated token is used to impersonate a legitimate user.

- Likelihood: 3

- Impact: 5

- Risk score: 15

- Rating: High

- Existing control: Token-based authentication

- Recommended controls: Strong signing configuration, expiration, signature validation, issuer validation, audience validation and secure token handling.

- Validation method: Source review and controlled local token-validation tests.

- Owner: Member 2

- Status: Open for assessment

 
---

 
## T3: Unauthorized field modification

 
- STRIDE category: Tampering

- Asset: A3 User information and business records

- Component: Backend APIs

- Data flow: DF4

- Trust boundary: TB2

- Threat scenario: A client supplies fields that should be assigned only by the server.

- Likelihood: 4

- Impact: 4

- Risk score: 16

- Rating: High

- Existing control: Application input handling

- Recommended controls: Request DTOs, explicit field allowlists, schema validation and server-side assignment of protected values.

- Validation method: Semgrep, source review and controlled negative API testing.

- Owner: Member 2

- Status: Selected for detailed investigation

 
---

 
## T4: Unauthorized object modification

 
- STRIDE category: Tampering

- Asset: A3, A4 and A6

- Component: Backend APIs

- Data flow: DF5 to DF10

- Trust boundary: TB2 and TB3

- Threat scenario: An authenticated user attempts to modify an object owned by another account.

- Likelihood: 4

- Impact: 5

- Risk score: 20

- Rating: Critical

- Existing control: Authentication

- Recommended controls: Object-level authorization, authenticated ownership lookup and deny-by-default access.

- Validation method: Controlled authorization testing using laboratory accounts.

- Owner: Member 1 or assigned vulnerability owner

- Status: Assigned separately

 
---

 
## T5: Insufficient security logging

 
- STRIDE category: Repudiation

- Asset: A10 Security logs

- Component: All backend services

- Data flow: All security-sensitive flows

- Trust boundary: TB2 to TB4

- Threat scenario: Security-sensitive operations cannot be reliably attributed to a user or request.

- Likelihood: 3

- Impact: 3

- Risk score: 9

- Rating: Medium

- Existing control: Application logging

- Recommended controls: Structured security events, timestamps, correlation IDs, protected logs and retention controls.

- Validation method: Application-log review following controlled tests.

- Owner: Member 2

- Status: Open for assessment

 
---

 
## T6: Excessive API data exposure

 
- STRIDE category: Information Disclosure

- Asset: A3, A4 and A6

- Component: Identity, community and workshop APIs

- Data flow: DF4 to DF10

- Trust boundary: TB2 and TB3

- Threat scenario: API responses include unnecessary internal or sensitive properties.

- Likelihood: 4

- Impact: 4

- Risk score: 16

- Rating: High

- Existing control: API response serialization

- Recommended controls: Response DTOs, field minimisation, authorization and generic error handling.

- Validation method: Response-field review and controlled local testing.

- Owner: Member 2

- Status: Open for assessment

 
---

 
## T7: CI/CD secret exposure

 
- STRIDE category: Information Disclosure

- Asset: A9 CI/CD credentials

- Component: Git repository and GitHub Actions

- Data flow: DF12 to DF15

- Trust boundary: TB6 and TB7

- Threat scenario: A credential is committed to Git or displayed in workflow output.

- Likelihood: 3

- Impact: 5

- Risk score: 15

- Rating: High

- Existing control: Repository access control

- Recommended controls: GitHub Secrets, secret scanning, log redaction, least privilege and credential rotation.

- Validation method: Gitleaks and workflow-log review.

- Owner: Member 3

- Status: Assigned separately

 
---

 
## T8: API resource exhaustion

 
- STRIDE category: Denial of Service

- Asset: Application availability

- Component: Public application endpoints

- Data flow: DF1 to DF7

- Trust boundary: TB1 and TB2

- Threat scenario: Excessive requests consume application or database resources.

- Likelihood: 3

- Impact: 4

- Risk score: 12

- Rating: High

- Existing control: Infrastructure capacity

- Recommended controls: Rate limits, quotas, request-size limits, timeouts and monitoring.

- Validation method: Configuration review only; disruptive testing is excluded.

- Owner: Member 4

- Status: Review only

 
---

 
## T9: Broken object-level authorization

 
- STRIDE category: Elevation of Privilege

- Asset: A3, A4 and A6

- Component: Backend APIs

- Data flow: DF5 to DF10

- Trust boundary: TB2

- Threat scenario: An authenticated user accesses an object belonging to another user because ownership is not validated.

- Likelihood: 4

- Impact: 5

- Risk score: 20

- Rating: Critical

- Existing control: Authentication

- Recommended controls: Central object-level authorization and deny-by-default ownership checks.

- Validation method: Controlled testing against local laboratory accounts.

- Owner: Member 1 or assigned owner

- Status: Assigned separately

 
---

 
## T10: Broken function-level authorization

 
- STRIDE category: Elevation of Privilege

- Asset: Privileged application functions

- Component: Backend routes

- Data flow: DF4

- Trust boundary: TB2

- Threat scenario: A standard user invokes a function intended for administrators or another privileged role.

- Likelihood: 3

- Impact: 5

- Risk score: 15

- Rating: High

- Existing control: Route-level authentication

- Recommended controls: Server-side role checks, policy enforcement and negative authorization tests.

- Validation method: Route review and controlled local testing.

- Owner: Member 4 or assigned owner

- Status: Assigned separately

 
---

 
## T11: Vulnerable or compromised dependency

 
- STRIDE category: Tampering

- Asset: A8 Application source and runtime integrity

- Component: Application dependencies and container images

- Data flow: Build process

- Trust boundary: CI/CD and software supply-chain boundary

- Threat scenario: A vulnerable or compromised third-party dependency affects application behaviour.

- Likelihood: 3

- Impact: 5

- Risk score: 15

- Rating: High

- Existing control: Version manifests and lock files

- Recommended controls: Dependency scanning, version pinning, approved sources and update review.

- Validation method: Software Composition Analysis.

- Owner: Member 3

- Status: Assigned separately

 
---

 
## T12: CI/CD workflow manipulation

 
- STRIDE category: Tampering and Elevation of Privilege

- Asset: A8 and A9

- Component: GitHub repository and GitHub Actions

- Data flow: DF12 to DF15

- Trust boundary: TB6 and TB7

- Threat scenario: An unsafe workflow change executes untrusted code or receives unnecessary permissions.

- Likelihood: 2

- Impact: 5

- Risk score: 10

- Rating: High

- Existing control: Repository permissions

- Recommended controls: Pull-request review, branch protection, least-privilege workflow permissions and reviewed action versions.

- Validation method: Workflow and repository-configuration review.

- Owner: Member 2 and Member 4

- Status: Open for assessment
