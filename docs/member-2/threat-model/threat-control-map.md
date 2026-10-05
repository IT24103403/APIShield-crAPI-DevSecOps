# OWASP crAPI Threat-to-Control Map

## Document Information

- *Project:* APIShield: A DevSecOps Security Pipeline for OWASP crAPI
- *Application:* OWASP Completely Ridiculous API (crAPI)
- *Document owner:* Member 2, Threat Modelling and SAST Engineer
- *Branch:* member2-threat-sast
- *Assessment environment:* Isolated Azure VM laboratory
- *Document status:* Completed
- *Purpose:* Map each identified STRIDE threat to its affected assets, architecture path, required controls, implementation locations, validation methods, evidence, owner, and current status.

---

## Mapping Method

This document connects the project threat model through the following traceability chain:

text
Threat
→ STRIDE category
→ Affected asset
→ Affected component
→ Data flow
→ Trust boundary
→ Required security control
→ Control location
→ Validation method
→ Evidence
→ Responsible owner
→ Current status


This file complements:

text
asset-register.md
stride-register.md
risk-assessment.md


The threat-control map does not replace the detailed threat descriptions or risk justifications. It provides a concise view of how each threat is addressed and how the relevant control can be verified.

---

# T1: Credential Impersonation

## Threat Context

- *STRIDE category:* Spoofing
- *Primary asset:* A1 - User Credentials
- *Affected service:* crapi-identity
- *Affected components:* Login, registration, password storage, and password-recovery functions
- *Relevant architecture path:* User/Client → crapi-web → Identity Service
- *Relevant trust boundaries:* Internet to Web Application and Web to Backend Services

## Threat Scenario

An attacker obtains, guesses, or reuses valid user credentials and authenticates as the affected user.

Successful credential impersonation may provide access to authenticated API operations and user-specific information.

## Existing Controls

- User authentication
- Password storage
- Identity-service validation
- Protected API endpoints
- Application authentication tokens

## Required Controls

- Secure password hashing
- Strong password requirements
- Authentication rate limiting
- Failed-login monitoring
- Generic authentication error messages
- Secure password-reset handling
- Session and token invalidation after password changes
- Protection against credential reuse where practical

## Control Location

text
Identity-service authentication logic
Password-validation configuration
Authentication middleware
Password-reset workflow
Application logging configuration


## Validation Method

- Review the password-handling implementation.
- Confirm that passwords are not stored in plaintext.
- Review authentication-error messages.
- Test repeated failed authentication attempts in the laboratory.
- Review failed-login event logging.
- Verify secure password-reset token handling.

## Responsible Owner

- *Primary owner:* Member 2
- *Supporting owner:* Shared application team

## Current Status

text
Status: Assessed
Control maturity: Partial
Further hardening: Recommended


---

# T2: Authentication Token Misuse

## Threat Context

- *STRIDE category:* Spoofing
- *Primary asset:* A2 - Authentication Tokens
- *Affected components:* Identity service, web layer, Workshop service, Community service, and other protected APIs
- *Relevant architecture path:* Authenticated API requests from the client through the web layer to backend services
- *Relevant trust boundaries:* Internet to Web Application and Web to Backend Services

## Threat Scenario

An attacker obtains, modifies, replays, or misuses an authentication token to access protected API functionality.

Token exposure may occur through:

- Unsafe screenshots
- Logs
- Shell scripts
- Browser exports
- Repository commits
- Insecure client storage
- Unprotected network transmission

## Existing Controls

- Authenticated API middleware
- Token-based API access
- Protected backend endpoints
- TLS-enabled service communication where configured

## Required Controls

- Token-signature verification
- Token-expiration validation
- Issuer and audience validation where applicable
- Secure token storage
- TLS-protected transmission
- Minimal token claims
- Token revocation or invalidation where supported
- Authorization-header redaction from logs
- Token redaction from screenshots and reports
- Exclusion of token-bearing scripts from Git

## Control Location

text
Identity-service token configuration
Backend authentication middleware
Client token-handling logic
Application logging configuration
.gitignore
Evidence-redaction procedures


## Validation Method

- Review authentication middleware.
- Test expired and modified tokens in the laboratory.
- Verify that invalid tokens are rejected.
- Search repository files for bearer tokens and JWT-like values.
- Review screenshots for exposed authorization headers.
- Confirm token-bearing scripts are not tracked.

## Responsible Owner

- *Primary owner:* Member 2
- *Supporting owner:* Member 3 for secret-management and repository controls

## Current Status

text
Status: Assessed
Evidence redaction: Required
Repository token exposure: Must be checked before merge


---

# T3: Unauthorized Field Modification

## Threat Context

- *STRIDE category:* Tampering
- *Threat name:* Unauthorized Field Modification
- *Primary asset:* A6 - Workshop, Order, and Refund Information
- *Affected service:* crapi-workshop
- *Affected component:* OrderControlView.put()
- *Affected endpoint:* PUT /workshop/api/shop/orders/{order_id}
- *Request data flow:* DF6 - Web to Workshop Service
- *Persistence data flow:* DF11 - Workshop Service to MongoDB Workshop Data
- *Request trust boundary:* TB2 - Web to Backend Services
- *Persistence trust boundary:* TB3 - Services to Databases
- *Risk score:* 16
- *Risk rating:* High

## Confirmed Threat Scenario

The original implementation directly assigned client input to the protected order-status property:

python
order.status = request_data["status"]


When the user submitted:

json
{
  "status": "returned"
}


the application executed refund-credit logic.

The controlled test produced:

text
Order ID: 49

Before:
Status = delivered
Available credit = 40

After:
Status = returned
Available credit = 50


The user bypassed the intended return-pending, QR-code, and physical-return process.

## Root Cause

The application performed:

- Authentication
- Order-ownership validation
- Status-enumeration validation

However, the application did not authorize the requested transition from:

text
delivered


directly to:

text
returned


The application confused a valid status value with an authorized business operation.

## Implemented Controls

- Reject every client-supplied status property in the general PUT endpoint.
- Return HTTP 403 for direct status-modification attempts.
- Remove the client-controlled status assignment.
- Remove immediate refund processing from the general update path.
- Preserve legitimate returns through the dedicated return endpoint.
- Add a targeted Semgrep rule.
- Execute the custom rule in GitHub Actions.
- Retest the exact exploit after rebuilding the service.

## Implemented Source Control

python
if "status" in request_data:
    return Response(
        {
            "message": "Direct status modification is not allowed."
        },
        status=status.HTTP_403_FORBIDDEN,
    )


## Control Location

text
crAPI/services/workshop/crapi/shop/views.py
semgrep-rules/crapi-mass-assignment.yml
.github/workflows/semgrep.yml


## Runtime Validation

Before remediation:

text
Exploit accepted
Order status: delivered → returned
Available credit: 40 → 50
Unauthorized refund: issued


After remediation:

text
HTTP 403 Forbidden
Order status: unchanged
Available credit: unchanged
Unauthorized refund: prevented


## SAST Validation

text
Targeted findings before remediation: 1
Targeted findings after remediation: 0


## CI/CD Validation

text
Unsafe pattern introduced
→ Custom Semgrep rule detected the pattern
→ GitHub Actions security job failed

Unsafe pattern removed
→ Custom rule returned no finding
→ GitHub Actions security job passed


## Evidence

text
M2_27_Shadow_PUT_Endpoint_Code.png
M2_28_Order_Status_Values.png
M2_30_Order_State_Before_Test.png
M2_31_Modified_PUT_Request_Redacted.png
M2_32_Vulnerable_PUT_Response.png
M2_33_Application_State_Before_After.png
M2_36_Secure_Code_Remediation.png
M2_37_Git_Diff.png
M2_41_Protected_Response.png
M2_42_No_State_Change.png
M2_46_Custom_Rule_Before_Fix.png
M2_47_Custom_Rule_After_Fix.png
M2_50_SAST_Before_After_Comparison.png
M2_55_Controlled_SAST_Failure.png
M2_56_SAST_Gate_Passed.png


## Responsible Owner

- *Primary owner:* Member 2

## Current Status

text
Status: Remediated and verified
Source remediation: Completed
Service rebuild: Completed
Runtime retest: Passed
Targeted SAST verification: Passed
CI/CD recurrence protection: Implemented


---

# T4: Unauthorized Object Modification

## Threat Context

- *STRIDE category:* Tampering
- *Primary assets:* User profiles, vehicle records, order records, and user-specific data
- *Affected components:* Backend object-access and object-update APIs
- *Relevant trust boundaries:* Web to Backend Services and Services to Databases

## Threat Scenario

An authenticated user modifies an object belonging to another user by changing an object identifier or accessing a route that lacks ownership validation.

## Required Controls

- Server-side object-ownership validation
- Deny-by-default object authorization
- Authorization on every object lookup
- Centralized authorization where practical
- Negative testing with two laboratory accounts
- Security logging for denied access attempts

## Control Location

text
Backend controller and view logic
Object-retrieval functions
Vehicle and order authorization controls
Authorization middleware


## Validation Method

- Access an object owned by the authenticated user.
- Attempt access to another laboratory user’s object.
- Confirm that unauthorized access is denied.
- Review server-side ownership checks.
- Confirm that authorization is enforced before returning or modifying data.

## Related Group Evidence

Member 1 investigated and remediated the BOLA vulnerability affecting vehicle-location access.

The remediation introduced a server-side owner check before returning another vehicle’s information.

## Responsible Owner

- *Primary owner:* Member 1

## Current Status

text
Status: Addressed through Member 1 BOLA remediation
Runtime retest: Completed
Unauthorized access after remediation: Denied


---

# T5: Insufficient Security Logging

## Threat Context

- *STRIDE category:* Repudiation
- *Primary asset:* A10 - Audit Logs, Scan Results, and Security Evidence
- *Affected components:* All backend services, authentication functions, security-sensitive workflows, and CI/CD jobs

## Threat Scenario

A sensitive action cannot be reliably attributed to a user, request, service, or workflow because security logs are absent or incomplete.

This may weaken:

- Incident investigation
- Accountability
- Evidence integrity
- Root-cause analysis
- Detection of repeat abuse

## Required Controls

- Structured security-event logging
- Accurate timestamps
- Authenticated-user identifiers
- Object identifiers
- Request or correlation identifiers
- Service name and operation
- Response result
- Protected log retention
- Token and credential redaction
- Consistent event naming

## Control Location

text
Application logging middleware
Backend service logging configuration
GitHub Actions logs
Security evidence directories
Repository commit and pull-request history


## Validation Method

- Execute controlled security tests.
- Review generated service and workflow logs.
- Confirm that critical actions can be attributed.
- Confirm that bearer tokens and credentials are not logged.
- Verify that security evidence is retained consistently.

## Responsible Owner

- *Owner:* Shared responsibility across all members

## Current Status

text
Status: Partially implemented
Evidence logging: Available
Structured application audit logging: Further improvement recommended


---

# T6: Excessive API Data Exposure

## Threat Context

- *STRIDE category:* Information Disclosure
- *Primary assets:* User profiles, vehicle information, order information, credit information, and authentication data
- *Affected components:* API responses, serializers, and error responses
- *Relevant trust boundary:* TB2 - Web to Backend Services

## Threat Scenario

An API response returns fields that are unnecessary for the client’s business function.

Excessive response data may expose:

- Internal identifiers
- User information
- Vehicle information
- Credit-related information
- Internal status values
- Implementation details
- Sensitive error data

## Required Controls

- Explicit response serializers
- Response DTOs
- Field minimization
- Object-level authorization
- Generic error responses
- Removal of internal-only properties
- Review of response schemas

## Control Location

text
API serializers
Response-construction logic
Controller and view implementations
Error-handling middleware


## Validation Method

- Review API response bodies.
- Compare returned fields with business requirements.
- Review serializer definitions.
- Confirm that internal-only values are excluded.
- Verify that error messages do not expose secrets or implementation details.

## Responsible Owner

- *Primary owner:* Member 2
- *Supporting owner:* Shared application team

## Current Status

text
Status: Assessed
Response minimization: Further review recommended


---

# T7: Secret Exposure

## Threat Context

- *STRIDE category:* Information Disclosure
- *Primary asset:* A9 - CI/CD Credentials and Pipeline Secrets
- *Affected components:* Git repository, Docker configuration, Kubernetes configuration, GitHub Actions, scripts, and evidence files
- *Relevant trust boundary:* TB5 - CI/CD to Environment

## Threat Scenario

Credentials, tokens, private keys, database passwords, or connection strings are stored in source control, printed in logs, exposed in screenshots, or passed to unnecessary services.

## Required Controls

- GitHub encrypted secrets
- Environment-variable injection
- Docker secrets where applicable
- Kubernetes Secrets where applicable
- .gitignore protection
- Safe .env.example placeholders
- Gitleaks scanning
- Token redaction
- Secret rotation after accidental exposure
- Least-privilege secret access

## Control Location

text
GitHub repository secrets
Docker Compose secret configuration
Kubernetes Secret manifests
.gitignore
.env.example
Member 3 secret-management controls
CI/CD secret-scanning stage


## Validation Method

- Run Gitleaks.
- Confirm real .env files are not tracked.
- Check staged files before committing.
- Search tracked files for bearer tokens or JWT-like values.
- Confirm screenshots are redacted.
- Confirm secrets are not printed in CI/CD logs.

## Responsible Owner

- *Primary owner:* Member 3
- *Supporting owner:* All members for evidence redaction and safe commits

## Current Status

text
Status: Implemented and validated
Gitleaks result: Passed
Real .env tracking: Prevented
Gitignore protection: Implemented


---

# T8: API Resource Exhaustion

## Threat Context

- *STRIDE category:* Denial of Service
- *Primary asset:* Application availability
- *Affected components:* Public endpoints, authenticated endpoints, databases, outgoing HTTP calls, and containers
- *Relevant trust boundaries:* Internet to Web Application and Web to Backend Services

## Threat Scenario

A client sends excessive requests, oversized input, repeated expensive operations, or requests that keep resources occupied.

Potential effects include:

- Service slowdown
- Database exhaustion
- Container-resource exhaustion
- Increased processing time
- Application unavailability

## Required Controls

- Request-rate limiting
- Request-size limits
- Connection and response timeouts
- User-level quotas
- Container CPU and memory limits
- Resource monitoring
- Graceful failure
- Cache controls where appropriate

## Control Location

text
Web ingress configuration
API gateway or proxy configuration
Backend service configuration
HTTP client configuration
Docker resource controls
Monitoring configuration


## Validation Method

- Review configured timeouts.
- Review container resource limits.
- Confirm oversized requests are rejected.
- Perform only controlled and non-disruptive validation.
- Review service behavior under repeated laboratory requests.

## Responsible Owner

- *Primary owner:* Member 4
- *Supporting owner:* Member 1 for container-resource controls

## Current Status

text
Status: Partially implemented
Timeout controls: Present in selected server-side requests
Container limits: Reviewed
Rate limiting: Further hardening recommended


---

# T9: Broken Object-Level Authorization

## Threat Context

- *STRIDE category:* Elevation of Privilege
- *Primary assets:* Vehicle records and user-specific information
- *Affected service:* Identity and vehicle APIs
- *Relevant trust boundary:* Web to Backend Services

## Threat Scenario

An authenticated user changes an object identifier and accesses another user’s object because the backend does not verify ownership.

## Required Controls

- Server-side object-ownership validation
- Deny-by-default access
- Uniform authorization on object lookups
- Negative testing with separate laboratory accounts
- Security logging for denied requests

## Control Location

text
Vehicle-location endpoint
Identity-service authorization logic
Backend object-retrieval controls


## Validation Method

- Access the authenticated user’s own vehicle information.
- Attempt access to another laboratory user’s vehicle.
- Confirm that unauthorized access is rejected.
- Review the source ownership check.

## Related Group Evidence

Member 1 confirmed and remediated a BOLA vulnerability in the vehicle-location functionality.

The corrected service verified that the requested vehicle owner matched the authenticated user.

## Responsible Owner

- *Primary owner:* Member 1

## Current Status

text
Status: Remediated and retested
Own-object access: Allowed
Other-user object access: Denied


---

# T10: Broken Function-Level Authorization

## Threat Context

- *STRIDE category:* Elevation of Privilege
- *Primary asset:* Restricted API functions
- *Affected components:* Privileged API routes and role-restricted operations
- *Relevant trust boundary:* Web to Backend Services

## Threat Scenario

A normal authenticated user invokes a restricted function because backend role or policy validation is missing.

## Required Controls

- Server-side role checks
- Explicit action policies
- Deny-by-default restricted routes
- Separation of normal and privileged operations
- Negative role-based testing
- Security logging

## Control Location

text
API route authorization
Controller and view authorization logic
Application policy layer
Role-validation middleware


## Validation Method

- Attempt restricted actions using a normal
