# OWASP crAPI Asset Register

 
## Assessment scope

 
This asset register covers the locally deployed OWASP crAPI application,

its microservices, associated data stores, source repository, CI/CD

workflow and security evidence.

 
## A1: User credentials

 
Description:

Usernames, email addresses, passwords and password-derived authentication data.

 
Security requirements:

- Confidentiality

- Integrity

- Secure password storage

- Secure transmission

- Protection against credential abuse

 
Relevant components:

- crapi-web

- crapi-identity

- postgresdb

 
Relevant data flows:

- DF1 User registration

- DF2 User login

 
## A2: Authentication tokens

 
Description:

Tokens used by authenticated users to access protected API functions.

 
Security requirements:

- Confidentiality

- Integrity

- Expiration

- Correct signature validation

- Correct issuer and audience validation where applicable

 
Relevant components:

- crapi-web

- crapi-identity

- Backend API services

 
Relevant data flows:

- DF3 Authentication token

- DF4 Authenticated API request

 
## A3: User profile information

 
Description:

Personal and application-specific information associated with a user account.

 
Security requirements:

- Confidentiality

- Integrity

- Object-level authorization

- Data minimisation

 
Relevant components:

- crapi-identity

- postgresdb

 
## A4: Vehicle information

 
Description:

Vehicle identifiers, vehicle records and information associated with ownership.

 
Security requirements:

- Confidentiality

- Integrity

- Ownership validation

- Object-level authorization

 
Relevant components:

- crapi-workshop

- mongodb

 
## A5: Community content

 
Description:

Posts, comments, uploaded content and related application interactions.

 
Security requirements:

- Integrity

- Availability

- Accountability

- Appropriate authorization

 
Relevant components:

- crapi-community

- mongodb

 
## A6: Workshop and mechanic information

 
Description:

Mechanic records, workshop requests, reports and vehicle service information.

 
Security requirements:

- Confidentiality

- Integrity

- Authorization

- Ownership validation

 
Relevant components:

- crapi-workshop

- mongodb

- Dealership API where applicable

 
## A7: Database records

 
Description:

Relational, document and vector data retained by the application.

 
Security requirements:

- Confidentiality

- Integrity

- Availability

- Backup and recovery

- Restricted service access

 
Relevant components:

- postgresdb

- mongodb

- chromadb

 
## A8: Application source code

 
Description:

Source code, configuration, Docker definitions and security rules.

 
Security requirements:

- Integrity

- Controlled access

- Secure change management

- Peer review

- SAST validation

 
Relevant components:

- GitHub repository

- Developer branches

- GitHub Actions

 
## A9: CI/CD credentials

 
Description:

Repository tokens, workflow credentials and application secrets used by CI/CD.

 
Security requirements:

- Confidentiality

- Least privilege

- Rotation

- Log redaction

- Secure storage

 
Relevant components:

- GitHub Secrets

- GitHub Actions

 
## A10: Security reports and audit logs

 
Description:

Semgrep outputs, workflow results, application logs and investigation evidence.

 
Security requirements:

- Integrity

- Availability

- Accountability

- Controlled access

- Retention

 
Relevant components:

- GitHub Actions artifacts

- Evidence directory

- Application logging
