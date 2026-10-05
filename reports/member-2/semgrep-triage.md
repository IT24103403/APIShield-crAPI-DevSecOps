# Semgrep Manual Triage

## Document Information

- *Project:* APIShield: A DevSecOps Security Pipeline for OWASP crAPI
- *Application:* OWASP Completely Ridiculous API (crAPI)
- *Role:* Member 2, Threat Modelling and SAST Engineer
- *Branch:* member2-threat-sast
- *Assessment environment:* Isolated Azure VM laboratory
- *Purpose:* Evaluate selected Semgrep findings using source-code context, input reachability, existing controls, runtime evidence, and business impact.

---

## Scan Information

- *Tool:* Semgrep Community Edition
- *General ruleset:* p/default
- *Targeted custom rule:* crapi-client-controlled-order-status
- *Custom rule file:* semgrep-rules/crapi-mass-assignment.yml
- *General scan scope:* crAPI/
- *General findings before remediation:* 143
- *General findings after remediation:* 143
- *Targets scanned:* 520
- *Targeted Mass Assignment findings before remediation:* 1
- *Targeted Mass Assignment findings after remediation:* 0
- *Output formats retained:* Terminal output, text output, JSON output, targeted before-and-after scan evidence, and GitHub Actions logs

The general result count remained unchanged because the remediation addressed one application-specific business-logic weakness while OWASP crAPI intentionally retained other unrelated vulnerable behaviours.

The targeted custom rule therefore provided the most relevant measurement for the specific Member 2 remediation.

---

## Triage Method

Each selected finding was assessed using the following criteria:

1. Semgrep rule identifier and scanner message.
2. Source file and matched code.
3. Whether the relevant input was externally controlled.
4. Input reachability from an application endpoint or CI/CD event.
5. Existing input-validation controls.
6. Existing authentication and authorization controls.
7. Potential confidentiality, integrity, and availability impact.
8. STRIDE category.
9. Asset, data-flow, and trust-boundary mapping.
10. Source-code and runtime evidence.
11. Required remediation and control location.
12. Post-remediation verification where applicable.

The following triage classifications were used:

- *Confirmed finding*
- *Likely finding*
- *Requires further evidence*
- *False positive*
- *Intentionally vulnerable training behaviour*
- *Confirmed insecure configuration with a documented laboratory limitation*

A Semgrep result was treated as a security-review signal rather than automatic proof of exploitability.

A finding was classified as confirmed only when supported by source-code evidence, runtime evidence, or both.

---

## SAST-01: GitHub Action Not Pinned to an Immutable Commit

### Scanner Result

- *Rule family:* yaml.github-actions.security.third-party-action-not-pinned-to-commit-sha
- *Severity:* Blocking security finding reported by the baseline scan
- *Affected location:* .github/workflows/
- *Matched pattern:* Third-party GitHub Actions referenced by mutable release tags
- *Example pattern:* actions/checkout@v4
- *Scanner concern:* A mutable action tag can resolve to modified upstream code and increase CI/CD supply-chain risk.

### Relevant Pattern

yaml
- name: Checkout source
  uses: actions/checkout@v4


### Manual Analysis

- *Is input user-controlled?* No direct application-user input is involved.
- *Administrative input:* Repository contributors can change workflow definitions through Git commits and pull requests.
- *Reachability:* The referenced action executes automatically when the configured GitHub Actions workflow is triggered.
- *Existing validation:* Repository permissions and pull-request review provide partial protection.
- *Missing control:* The action reference is not immutable because a release tag may be changed upstream.
- *Potential impact:* Unexpected or compromised upstream action code could execute within the CI runner, access checked-out source code, influence generated artifacts, or interact with credentials available to the job.
- *STRIDE mapping:* Tampering and Elevation of Privilege.
- *Asset mapping:* A8 Application Source Code and Configuration; A9 CI/CD Credentials and Pipeline Secrets.
- *Trust boundary:* Repository and workflow configuration to GitHub-hosted runner.
- *Triage decision:* *Likely finding*.

### Decision Rationale

The finding is technically valid because a release tag is a mutable reference.

The workflow depends on the upstream action maintainer continuing to serve trusted code using that tag. However, the assessment found no evidence that any referenced action had been compromised.

The issue is therefore not presented as a confirmed CI/CD compromise. It is classified as a likely supply-chain weakness requiring preventive hardening.

The potential impact also depends on the workflow permissions and secrets available to the affected job.

### Recommended Action

Pin third-party GitHub Actions to reviewed full commit SHAs.

The friendly release version may be retained as a comment:

yaml
- name: Checkout source
  uses: actions/checkout@FULL_REVIEWED_COMMIT_SHA # v4


Additional controls should include:

- Least-privilege workflow permissions
- Pull-request review for .github/workflows/
- Branch protection for the default branch
- Restricted secret exposure in pull-request workflows
- Periodic review of pinned action versions
- Dependabot or an equivalent update-review mechanism

### Control Location

text
.github/workflows/
GitHub branch-protection settings
GitHub Actions workflow permissions
Pull-request review policy


### Final Status

text
Status: Open hardening recommendation
Remediation: Not included in the Mass Assignment source change
Verification required: Pin actions and rerun the workflow


---

## SAST-02: Client-Controlled Order Status Assignment

### Scanner Result

- *Rule ID:* crapi-client-controlled-order-status
- *Severity:* ERROR
- *Affected source:* Preserved vulnerable version of services/workshop/crapi/shop/views.py
- *Matched code:* order.status = request_data["status"]
- *Scanner message:* Client-controlled request data is assigned directly to order status. Restrict status transitions to trusted server-side workflows.
- *Targeted findings before remediation:* 1
- *Targeted findings after remediation:* 0

### Relevant Vulnerable Pattern

python
if "status" in request_data and request_data["status"] != order.status:
    order.status = request_data["status"]

    if request_data["status"] == Order.STATUS_CHOICES.RETURNED.value:
        user_details.available_credit += float(
            order.quantity * order.product.price
        )
        user_details.save()


### Manual Analysis

- *Is input user-controlled?* Yes.
- *Evidence of input control:* The status property was supplied in the JSON body of an authenticated PUT request.
- *Affected endpoint:* PUT /workshop/api/shop/orders/{order_id}
- *Existing authentication:* The endpoint required a valid authenticated user.
- *Existing ownership validation:* The endpoint verified that the requesting user owned the selected order.
- *Existing input validation:* The endpoint verified that the submitted value existed in Order.STATUS_CHOICES.
- *Missing authorization:* The application did not determine whether the client was authorized to transition directly from delivered to returned.
- *Reachability:* Confirmed through controlled runtime testing.
- *Potential impact:* Unauthorized order-state modification, return-workflow bypass, unauthorized refund credit, and financial-integrity failure.
- *STRIDE mapping:* Tampering.
- *Asset mapping:* A6 Workshop, Order, and Refund Information.
- *Data-flow mapping:* DF6 and DF11.
- *Trust-boundary mapping:* TB2 and TB3.
- *Likelihood:* 4
- *Impact:* 4
- *Risk score:* 16
- *Risk rating:* High
- *Triage decision:* *Confirmed finding*.

### Runtime Evidence

A laboratory-owned order was used for the controlled test.

#### State Before Exploitation

text
Order ID: 49
Status: delivered
Available credit: 40


#### Modified Request

http
PUT /workshop/api/shop/orders/49
Authorization: Bearer [REDACTED]
Content-Type: application/json


json
{
  "status": "returned"
}


#### State After Exploitation

text
Order ID: 49
Status: returned
Available credit: 50


The order moved directly from delivered to returned.

The available credit increased from 40 to 50 without completing the legitimate return process involving:

text
Return pending
→ QR code
→ Physical return
→ Final refund


### Decision Rationale

The finding was confirmed through both source-code analysis and controlled runtime evidence.

Authentication established the identity of the requester. The ownership check confirmed that the order belonged to the requester. Enumeration validation confirmed that returned was syntactically valid.

However, none of these controls authorized the user to perform the final business-state transition.

The application incorrectly treated a valid status value as an authorized operation.

The persistent order-state change and credit increase demonstrated direct integrity, workflow, and financial impact.

### Root Cause

The root cause was missing authorization over business-state transitions.

The application validated the submitted value but did not enforce an allowed transition model.

The following distinction was important:

text
Valid value:
"returned" exists in STATUS_CHOICES

Authorized transition:
The client is permitted to move the order directly to "returned"


The first condition was true.

The second condition was not checked.

### Implemented Remediation

The general PUT endpoint now rejects any client-supplied status property:

python
if "status" in request_data:
    return Response(
        {
            "message": "Direct status modification is not allowed."
        },
        status=status.HTTP_403_FORBIDDEN,
    )


Legitimate order returns remain available through the dedicated return-order workflow.

### Post-Remediation Verification

After rebuilding and recreating the workshop service, the same attack pattern was submitted again.

The retest used:

- The same HTTP method
- The same endpoint pattern
- The same protected status property
- The same returned value

Observed result:

text
HTTP 403 Forbidden
Direct status modification is not allowed.
Order status unchanged
Available credit unchanged


The targeted Semgrep comparison confirmed:

text
Before remediation: 1 finding
After remediation: 0 findings


### Recommended Action

The implemented control should be retained.

Additional defence-in-depth controls may include:

- Dedicated request DTOs that exclude protected fields
- Explicit server-side state-transition rules
- Audit logging for rejected status-change attempts
- Unit tests for unauthorized state transitions
- Integration tests for the legitimate return workflow
- CI/CD execution of the custom Semgrep rule
- Pull-request review for changes to order and refund logic

### Control Location

text
crAPI/services/workshop/crapi/shop/views.py
semgrep-rules/crapi-mass-assignment.yml
.github/workflows/semgrep.yml


### Final Status

text
Status: Confirmed vulnerability
Remediation: Completed
Runtime verification: Passed
Targeted SAST verification: Passed
Before targeted findings: 1
After targeted findings: 0


---

## SAST-03: Disabled TLS Certificate Verification in a Server-Side Request

### Scanner and Source Result

- *Finding type:* Insecure transport configuration identified during Semgrep-assisted source review
- *Source file:* services/workshop/crapi/shop/views.py
- *Relevant pattern:* A server-side requests.post(...) operation includes verify=False
- *Security concern:* The application does not verify the remote TLS certificate for the affected request.

### Relevant Code Pattern

python
payment_response = requests.post(
    gateway_endpoint,
    headers={
        "Authorization": gateway_credential,
        "Content-Type": "application/json",
    },
    json=data,
    verify=False,
    timeout=5,
)


### Manual Analysis

- *Is input user-controlled?* The verify=False configuration is not directly user-controlled.
- *Reachability:* The request is executed by workshop-service business logic when the associated server-side operation is performed.
- *Existing authentication:* The parent application workflow requires authentication.
- *Existing timeout:* The request includes an explicit five-second timeout.
- *Existing transport encryption:* HTTPS may encrypt the connection.
- *Missing control:* The client does not verify the identity of the downstream TLS peer.
- *Potential impact:* In an untrusted network, a machine-in-the-middle could impersonate the downstream service, observe transmitted information, alter requests, or manipulate returned responses.
- *Sensitive data involved:* User information, order details, authorization data, payment-related data, or downstream service responses may traverse the connection.
- *STRIDE mapping:* Spoofing, Tampering, and Information Disclosure.
- *Asset mapping:* A2 Authentication Tokens; A6 Workshop, Order, and Refund Information; A7 Database and Service Data.
- *Trust boundary:* Backend service to downstream service.
- *Triage decision:* *Confirmed insecure configuration with a documented laboratory limitation*.

### Decision Rationale

The insecure configuration is directly present in the application source and disables a standard TLS peer-authentication control.

The assessment did not demonstrate a machine-in-the-middle attack. Therefore, the report does not claim that traffic was intercepted, read, or changed during laboratory testing.

The isolated crAPI environment uses internal certificate configuration. This explains the current laboratory setting but does not make the configuration suitable for a production deployment.

Encryption without certificate verification does not reliably establish the identity of the downstream service.

### Recommended Action

A production deployment should:

1. Remove verify=False.
2. Enable TLS certificate verification.
3. Use a certificate issued by a trusted certificate authority.
4. Alternatively, configure an approved internal CA bundle.
5. Restrict outbound destinations using an explicit allowlist.
6. Disable unnecessary redirects.
7. Apply explicit connection and response timeouts.
8. Validate destinations before forwarding authorization credentials.
9. Fail closed when certificate validation fails.
10. Monitor and log failed downstream verification attempts without recording secrets.

Any temporary laboratory exception should include:

- Technical justification
- Compensating control
- Named security owner
- Expiration date
- Remediation plan
- Approval status

### Control Location

text
services/workshop/crapi/shop/views.py
Application certificate configuration
Container trust store
Security exception register


### Final Status

text
Status: Confirmed insecure configuration
Laboratory treatment: Documented exception
Production treatment: Remediation required
Runtime machine-in-the-middle exploit: Not demonstrated


---

## Triage Summary

| ID | Finding | Decision | STRIDE Mapping | Primary Asset | Required Action |
|---|---|---|---|---|---|
| SAST-01 | GitHub Action not pinned to an immutable commit SHA | Likely finding | Tampering and Elevation of Privilege | A8 Application Source Code and A9 CI/CD Credentials | Pin third-party actions to reviewed commit SHAs, use least-privilege permissions, and require workflow review. |
| SAST-02 | Client-controlled order-status assignment | Confirmed finding | Tampering | A6 Workshop, Order, and Refund Information | Completed: reject direct status changes, rebuild the service, repeat the exploit, and retain the targeted Semgrep gate. |
| SAST-03 | TLS certificate verification disabled | Confirmed insecure configuration with documented laboratory limitation | Spoofing, Tampering, and Information Disclosure | A2 Authentication Tokens, A6 Workshop Data, and A7 Service Data | Enable certificate verification using a trusted certificate or approved CA bundle and document temporary exceptions. |

---

## Triage Outcome Analysis

### SAST-01 Outcome

The unpinned-action result identifies a credible software-supply-chain weakness.

GitHub Actions executes third-party action code in the CI runner. Referencing an action through a mutable release tag means the workflow does not immutably identify the reviewed source revision.

No evidence demonstrated a compromised action in the project. Therefore, the finding remains a likely risk and a hardening recommendation rather than a confirmed compromise.

The final control should pin actions to reviewed full commit SHAs and restrict workflow permissions.

### SAST-02 Outcome

The client-controlled order-status assignment was a confirmed and exploitable business-logic weakness.

Runtime testing demonstrated:

text
Before:
Status = delivered
Credit = 40

After exploit:
Status = returned
Credit = 50


The vulnerable logic was removed from the general PUT endpoint.

Post-remediation testing demonstrated:

text
HTTP 403 Forbidden
Status unchanged
Credit unchanged


The targeted custom rule also produced:

text
Before remediation = 1 finding
After remediation = 0 findings


The finding is therefore recorded as confirmed, remediated, redeployed, retested, and protected against recurrence.

### SAST-03 Outcome

The use of verify=False is a confirmed insecure TLS configuration because it disables peer-certificate verification.

The laboratory environment used internal certificate configuration, so the limitation was documented rather than presented as evidence of an actual interception attack.

Production deployment requires certificate verification, trusted certificates or a configured CA bundle, restricted outbound destinations, and formal exception management.

---

## Overall Triage Conclusion

Manual triage added application, infrastructure, and business context to the automated findings.

The general Semgrep scans reported:

text
General findings before remediation: 143
General findings after remediation: 143
Targets scanned: 520


The unchanged general count does not indicate failure of the Mass Assignment remediation.

OWASP crAPI intentionally retains multiple unrelated vulnerable behaviours. The Member 2 remediation addressed one application-specific business-logic weakness.

The custom rule provided the relevant targeted measurement:

text
Vulnerable source:
1 crapi-client-controlled-order-status finding

Remediated source:
0 crapi-client-controlled-order-status findings


The three selected findings represent different security outcomes:

1. *SAST-01:* A credible CI/CD supply-chain risk requiring proactive hardening.
2. *SAST-02:* A confirmed business-logic vulnerability supported by source analysis and runtime exploitation.
3. *SAST-03:* A confirmed insecure TLS configuration with a documented laboratory limitation and a stricter production requirement.

This distinction prevents scanner output from being overstated.

It also demonstrates that SAST findings must be evaluated using:

- Source-code context
- External-input control
- Data-flow reachability
- Existing validation
- Existing authorization
- Trust boundaries
- Business impact
- Runtime evidence
- Deployment environment
- Remediation evidence
- Post-remediation verification

---

## Evidence References

| Evidence | Purpose |
|---|---|
| Semgrep baseline scan summary | Demonstrates general scan scope, target count, and finding count. |
| Semgrep manual-triage screenshots | Shows that selected findings were reviewed rather than copied automatically. |
| Normal order request | Establishes the legitimate order-creation payload. |
| Normal order response | Establishes expected server-calculated credit behaviour. |
| Modified POST request with credit: 9999 | Demonstrates the initial negative property test. |
| Protected POST response | Shows that the injected credit value was ignored. |
| URL route mapping | Connects the order-specific endpoint to OrderControlView. |
| Vulnerable OrderControlView.put() source | Shows the client-controlled status assignment and refund logic. |
| Order status enumeration | Confirms delivered, return pending, and returned as valid values. |
| Order state before the exploit | Establishes delivered and credit 40. |
| Redacted PUT exploit request | Shows the status: returned payload without exposing the bearer token. |
| Vulnerable PUT response | Shows that the submitted status was accepted. |
| Before-and-after application state | Demonstrates delivered → returned and credit 40 → 50. |
| Root-cause analysis | Explains missing business-state authorization. |
| Secure-code remediation | Shows the HTTP 403 control. |
| Git diff | Shows removal of the vulnerable block and introduction of the control. |
| Security-fix commit | Provides version-control traceability. |
| Workshop rebuild evidence | Shows deployment of the corrected source. |
| Post-remediation request | Shows the exact exploit was repeated. |
| Protected response | Shows HTTP 403 after remediation. |
| No-state-change evidence | Confirms status and credit remained unchanged. |
| Custom Semgrep rule | Shows the application-specific recurrence-detection control. |
| Custom-rule validation | Confirms that the rule configuration is valid. |
| Vulnerable-source custom scan | Shows one targeted finding before remediation. |
| Remediated-source custom scan | Shows zero targeted findings after remediation. |
| GitHub Actions workflow | Shows automated default and custom Semgrep execution. |
| Controlled SAST failure | Demonstrates that the gate can block the prohibited pattern. |
| Passing SAST rerun | Demonstrates successful verification after removing the regression. |

---

## Final Triage Status

| ID | Final Status | Remediation Status | Verification Status |
|---|---|---|---|
| SAST-01 | Open hardening recommendation | Not remediated as part of the order-status fix | Requires immutable action pinning and workflow review |
| SAST-02 | Confirmed vulnerability | Remediated | Runtime retest passed and targeted findings reduced from 1 to 0 |
| SAST-03 | Confirmed insecure configuration with laboratory exception | Production remediation recommended | Source confirmed; no machine-in-the-middle exploit claimed |

---

## Final Statement

The Semgrep manual-triage process demonstrated that automated scanner output must be interpreted rather than copied directly into a security report.

The Mass Assignment finding was supported by the following evidence chain:

text
DFD and trust boundaries
→ STRIDE threat identification
→ Risk assessment
→ SAST baseline
→ Normal application workflow
→ Initial negative property test
→ Source investigation
→ Controlled exploit
→ Persistent business impact
→ Root-cause analysis
→ Secure code change
→ Service rebuild
→ Exact exploit retest
→ Targeted SAST comparison
→ Automated CI/CD enforcement


The final conclusion is that the client-controlled order-status vulnerability was successfully identified, exploited inside the authorized laboratory, remediated, deployed, retested, and protected against recurrence using an application-specific Semgrep security gate.
