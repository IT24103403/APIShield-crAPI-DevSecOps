# Root-Cause Analysis: Client-Controlled Order Status

## Document Information

- **Project:** APIShield: A DevSecOps Security Pipeline for OWASP crAPI
- **Application:** OWASP Completely Ridiculous API (crAPI)
- **Finding ID:** V-02
- **Vulnerability:** Mass Assignment / Unsafe Property Update
- **Owner:** Member 2, Threat Modelling and SAST Engineer
- **Branch:** `member2-threat-sast`
- **Assessment environment:** Isolated Azure VM laboratory
- **Analysis status:** Completed
- **Remediation status:** Implemented and verified

---

## Executive Root-Cause Summary

The confirmed vulnerability was caused by missing authorization over protected order-state transitions.

The affected endpoint accepted a client-controlled `status` property and assigned the submitted value directly to the server-side Order object.

When the submitted status equalled `returned`, the application immediately executed refund-credit logic.

The application already implemented authentication, order-ownership validation, and status-enumeration validation. However, none of these controls determined whether the authenticated user was authorized to move an order directly from:

```text
delivered
```

to:

```text
returned
```

The application therefore confused:

```text
A recognised and syntactically valid status value
```

with:

```text
An authorized business-state transition
```

This missing transition authorization allowed an authenticated user to bypass the intended return process and receive unauthorized refund credit.

---

## Vulnerability Identification

### Classification

- **Finding ID:** V-02
- **Vulnerability:** Mass Assignment / Unsafe Property Update
- **OWASP API category:** API6:2019 - Mass Assignment
- **STRIDE category:** Tampering
- **Threat ID:** T3 - Unauthorized Field Modification
- **Primary asset:** A6 - Workshop, Order, and Refund Information
- **Risk rating:** High
- **Final status:** Remediated and verified

### Affected Application Components

- **Affected service:** `crAPI-workshop`
- **Affected endpoint:** `PUT /workshop/api/shop/orders/{order_id}`
- **Affected view:** `OrderControlView`
- **Affected method:** `OrderControlView.put()`
- **Affected model:** `Order`
- **Affected credit property:** `UserDetails.available_credit`

### Affected Source Files

```text
crAPI/services/workshop/crapi/shop/urls.py
crAPI/services/workshop/crapi/shop/views.py
crAPI/services/workshop/crapi/shop/models.py
crAPI/services/workshop/crapi/shop/serializers.py
```

---

## Final DFD Architecture Mapping

The final Data Flow Diagram maps the vulnerability to the Workshop request and persistence paths.

### Request Data Flow

```text
DF6: Web → Workshop Service
```

DF6 represents authenticated Workshop API requests sent from `crAPI-web` to `crAPI-workshop`.

The client-controlled `status` property entered the affected service through this data flow.

### Persistence Data Flow

```text
DF11: Workshop Service → MongoDB Workshop Data
```

DF11 represents the Workshop service reading and writing:

- Orders
- Order status
- Refund credits
- Order records

The unauthorized `returned` status and credit change were persisted through this data flow.

### Request Trust Boundary

```text
TB2: Web → Backend Services
```

The untrusted client-controlled property crossed TB2 when the web layer forwarded the authenticated API request to the Workshop backend service.

### Persistence Trust Boundary

```text
TB3: Services → Databases
```

The persistent business impact crossed TB3 when the Workshop service wrote the unauthorized order status and refund-credit information to MongoDB Workshop Data.

### Complete Vulnerability Path

```text
User / Client
        ↓
DF3: Authenticated API request
        ↓
crAPI-web
        ↓
DF6: Workshop API request
        ↓
TB2: Web → Backend Services
        ↓
crAPI-workshop
        ↓
OrderControlView.put()
        ↓
Client-controlled status read from request data
        ↓
order.status assigned from client input
        ↓
Refund-credit logic executed
        ↓
DF11: Read/write order status and refund data
        ↓
TB3: Services → Databases
        ↓
MongoDB Workshop Data
        ↓
Unauthorized order status and credit persisted
```

### CI/CD Trust Boundary

The final DFD also contains:

```text
TB5: CI/CD → Environment
```

TB5 is relevant to the custom Semgrep rule and automated regression protection.

TB5 is not part of the runtime exploit path. It represents the boundary crossed when pipeline-approved code and container changes are deployed to the environment.

---

## Confirmed Runtime Result

A controlled security test was performed using a laboratory-owned order.

### State Before Exploitation

```text
Order ID: 49
Order status: delivered
Available credit: 40
```

### Submitted Request Body

```json
{
  "status": "returned"
}
```

### State After Exploitation

```text
Order ID: 49
Order status: returned
Available credit: 50
```

### Confirmed Persistent Changes

```text
Order status:
delivered → returned

Available credit:
40 → 50
```

The order-status and credit changes remained visible after the request completed and the application state was refreshed.

The result therefore represented a persistent server-side modification rather than a temporary response-only value.

---

## Expected Business Workflow

The intended return workflow was:

```text
Delivered order
        ↓
User selects Return Order
        ↓
POST /workshop/api/shop/orders/return_order
        ↓
Order status becomes return pending
        ↓
Application generates a return QR code
        ↓
User completes the physical product return
        ↓
Trusted workflow changes status to returned
        ↓
Refund credit is issued
```

This workflow separates return initiation from final return completion.

The client should be able to request a return, but the client should not be able to select the final refund-producing status.

---

## Vulnerable Business Workflow

The vulnerable path allowed:

```text
Delivered order
        ↓
Client submits status: returned
        ↓
General PUT endpoint accepts the value
        ↓
Server changes order directly to returned
        ↓
Refund-credit logic executes
        ↓
Unauthorized credit is issued
```

This skipped:

- The `return pending` state
- QR-code generation
- Physical product return
- Trusted return-completion processing
- Server-controlled confirmation of the final state

The vulnerability was therefore a business-logic authorization failure, not simply a malformed-input issue.

---

## Normal Workflow and Initial Negative Test

Before identifying the confirmed vulnerability, the normal order-creation workflow was established.

### Normal Request

```http
POST /workshop/api/shop/orders
Authorization: Bearer [REDACTED]
Content-Type: application/json
```

```json
{
  "product_id": 2,
  "quantity": 1
}
```

The application created the order and calculated the available credit using backend logic.

### Modified Initial Test

The same request was replayed with an unexpected credit property:

```json
{
  "product_id": 2,
  "quantity": 1,
  "credit": 9999
}
```

### Initial Test Result

The application ignored the client-provided `credit` value.

The server continued calculating credit through backend business logic.

### Initial Test Conclusion

No Mass Assignment vulnerability was confirmed for the tested `credit` property at the POST order endpoint.

This negative result was retained because it demonstrated:

- Establishment of the legitimate baseline
- Controlled request modification
- Evidence-based rejection of an incorrect hypothesis
- Avoidance of overstating vulnerability
- Continued investigation after the first property was protected

The confirmed vulnerability involved the `status` property at the order-specific PUT endpoint, not the `credit` property at the POST endpoint.

---

## Source-to-Impact Trace

Source investigation established the following trace:

```text
Authenticated browser request
        ↓
PUT /workshop/api/shop/orders/{order_id}
        ↓
Order-specific route in urls.py
        ↓
OrderControlView.put()
        ↓
request.data assigned to request_data
        ↓
Client-controlled status read from request_data
        ↓
Status enumeration checked
        ↓
order.status assigned from client data
        ↓
returned value triggers refund logic
        ↓
UserDetails.available_credit increased
        ↓
Order and credit values saved
        ↓
Persistent data written through DF11
```

This trace connected the client-controlled request property to the final persistent impact.

---

## Vulnerable Source Pattern

The PUT handler accepted the request body:

```python
request_data = request.data
```

The client-supplied status was then assigned directly to the Order object:

```python
if "status" in request_data and request_data["status"] != order.status:
    order.status = request_data["status"]
```

When the submitted value equalled `returned`, refund-credit logic executed:

```python
if request_data["status"] == Order.STATUS_CHOICES.RETURNED.value:
    user_details.available_credit += float(
        order.quantity * order.product.price
    )
    user_details.save()
```

The updated order state was also saved.

The implementation therefore connected one client-controlled property directly to:

- Persistent order-state modification
- Refund-credit processing
- Financial business data
- MongoDB Workshop Data

---

## Order-Status Enumeration

The Order model defined the following valid status values:

```python
STATUS_CHOICES = Choices(
    ("DELIVERED", "delivered", "delivered"),
    ("RETURN_PENDING", "return pending", "return pending"),
    ("RETURNED", "returned", "returned"),
)
```

The exploit used:

```text
returned
```

The endpoint verified that `returned` was a recognised model value.

However, enumeration validation only answered:

```text
Is this a known status value?
```

It did not answer:

```text
Is the authenticated client authorized to perform
this transition at this stage of the workflow?
```

---

## Why the Existing Controls Failed

The endpoint contained several valid security controls. Each control answered a different question.

### Authentication

Authentication established:

```text
Who submitted the request?
```

Authentication confirmed that a valid user submitted the request.

Authentication did not authorize the user to choose the final refund-producing state.

### Ownership Validation

The endpoint confirmed that the order belonged to the authenticated user.

Ownership validation established:

```text
Does this order belong to the requester?
```

This control helped prevent modification of another user’s order.

However, ownership did not authorize every possible change to the owned order.

An order owner should not automatically be permitted to:

- Mark an order as returned
- Confirm completion of a physical return
- Approve a refund
- Issue account credit
- Select internal workflow states

### Status-Enumeration Validation

The endpoint validated that the submitted value existed in:

```python
Order.STATUS_CHOICES
```

This established:

```text
Is the supplied status recognised by the model?
```

Because `returned` was a valid status, it passed the enumeration check.

The missing authorization question was:

```text
May this client move this order directly
from delivered to returned?
```

### Ownership Was Not Transition Authorization

The endpoint treated ownership of an order as sufficient permission to modify its protected business state.

This was incorrect because the final return status depended on completion of a trusted workflow.

The final `returned` state should have remained under server-side workflow control.

---

## Five-Whys Analysis

### Why 1: Why did the user receive unauthorized refund credit?

Because the application accepted `status: returned` and executed the refund-credit logic.

### Why 2: Why did the application accept the returned status?

Because the general PUT endpoint allowed the client to submit the protected `status` property.

### Why 3: Why could the client control the protected status?

Because the endpoint directly assigned:

```python
order.status = request_data["status"]
```

without separating client-editable properties from server-controlled properties.

### Why 4: Why did validation not block the request?

Because validation checked only whether `returned` was a recognised status value.

The application did not validate whether the transition from `delivered` to `returned` was authorized.

### Why 5: Why was the transition not authorized explicitly?

Because order-state changes were not implemented as an explicit server-side state-transition policy.

### Primary Root Cause

```text
Missing server-side authorization for protected business-state transitions
```

### Contributing Cause

```text
A protected model property was exposed through a general client-controlled update endpoint
```

### Impact-Amplifying Cause

```text
Refund-credit logic executed immediately after the client-controlled
status changed to returned
```

---

## Root-Cause Classification

### Primary Security Cause

Missing business-transition authorization.

### Secondary Security Cause

Unsafe direct assignment of client-controlled request data to a protected object property.

### Design Cause

The endpoint failed to separate:

```text
Client-editable order properties
```

from:

```text
Server-controlled business-state properties
```

### Business-Logic Cause

Refund-credit processing trusted a final order state selected through a general client request.

### Validation Cause

Value validation was implemented, but operation authorization was missing.

### Workflow Cause

The general PUT endpoint duplicated functionality that should have remained inside the dedicated return workflow.

---

## Business and Security Impact

### Order Integrity

The user modified a protected order-state value.

The server persisted the unauthorized state.

### Financial Integrity

The application increased available credit from 40 to 50.

The credit was issued without completion of the required return process.

### Workflow Integrity

The required intermediate state:

```text
return pending
```

was bypassed.

The QR-code and physical-return stages were also bypassed.

### Data Integrity

The unauthorized status and credit values were written to Workshop MongoDB through DF11.

The stored data incorrectly represented the state of the product return.

### Audit Reliability

The persisted record indicated that the order had reached the final returned state even though the trusted return process had not been completed.

### Potential Repeatability

The vulnerable behavior existed in a reusable authenticated endpoint.

An authenticated user with additional eligible orders could potentially repeat the same business-logic abuse.

No large-scale repetition was performed during the authorized assessment.

---

## STRIDE and Architecture Mapping

### STRIDE Classification

- **Primary STRIDE category:** Tampering
- **Threat ID:** T3 - Unauthorized Field Modification

The vulnerability was classified as Tampering because a client modified protected server-side business data.

### Primary Asset

```text
A6 - Workshop, Order, and Refund Information
```

The affected information included:

- Order status
- Available credit
- Return-processing state
- Refund records

### Request Flow

```text
DF6: Web → Workshop Service
```

DF6 carried the client-controlled Workshop API request into the affected backend service.

### Persistence Flow

```text
DF11: Workshop Service → MongoDB Workshop Data
```

DF11 persisted the unauthorized order status and refund-credit information.

### Request Boundary

```text
TB2: Web → Backend Services
```

The client-controlled status crossed TB2 when the request entered `crAPI-workshop`.

### Persistence Boundary

```text
TB3: Services → Databases
```

The persistent state change crossed TB3 when the Workshop service wrote the order and refund data to MongoDB.

### CI/CD Boundary

```text
TB5: CI/CD → Environment
```

TB5 applies to deployment and automated recurrence prevention.

The custom Semgrep rule and security workflow protect this boundary by preventing the vulnerable assignment pattern from being deployed again.

---

## Risk Assessment

### Likelihood

```text
Likelihood: 4 - Likely
```

The affected endpoint was reachable by an authenticated user.

The required property and value were discoverable through:

- Browser network traffic
- Application behavior
- API responses
- Source-code review
- Model enumeration

### Impact

```text
Impact: 4 - Major
```

The request changed persistent order state and caused unauthorized refund credit.

The issue affected:

- Order integrity
- Financial integrity
- Workflow integrity
- Stored data reliability

### Risk Score

```text
Risk score = Likelihood × Impact
Risk score = 4 × 4
Risk score = 16
Risk rating = High
```

This is the project’s chosen qualitative scoring method rather than an official OWASP crAPI rating.

---

## Implemented Remediation

The general PUT endpoint was modified to reject every client-supplied `status` property:

```python
if "status" in request_data:
    return Response(
        {
            "message": "Direct status modification is not allowed."
        },
        status=status.HTTP_403_FORBIDDEN,
    )
```

The vulnerable direct status assignment and refund-credit block were removed from the general order-update endpoint.

The dedicated return endpoint remains responsible for legitimate return initiation:

```http
POST /workshop/api/shop/orders/return_order
```

---

## Why the Remediation Addresses the Root Cause

The remediation does not merely block the demonstrated string value.

The remediation removes client authority over the entire protected status property.

This addresses the root cause because:

1. The general update endpoint can no longer select a protected order status.
2. A client cannot directly select the final refund-producing state.
3. Refund logic is no longer triggered by status supplied through the general PUT endpoint.
4. Legitimate return initiation remains inside the dedicated workflow.
5. The server remains responsible for trusted state transitions.
6. The targeted Semgrep rule detects reintroduction of the unsafe assignment pattern.
7. GitHub Actions can block the prohibited pattern before deployment across TB5.

---

## Service Rebuild and Deployment Verification

After the source-code remediation:

1. The Workshop source was rebuilt.
2. The remediated service image was created or deployed.
3. The Workshop container was recreated.
4. Container status was checked.
5. Startup logs were reviewed.
6. The service was made available for runtime retesting.

The new HTTP 403 behavior confirmed that the active Workshop service contained the corrected implementation.

---

## Post-Remediation Verification

### Exact Runtime Retest

The same exploit pattern was repeated after the Workshop service rebuild.

The retest used:

- The same HTTP method
- The same endpoint pattern
- The same protected `status` property
- The same `returned` value
- A fresh laboratory-owned order

The remediated endpoint returned:

```text
HTTP 403 Forbidden
Direct status modification is not allowed.
```

The order status and available credit remained unchanged.

### Source Verification

The corrected source contained:

```text
Direct status modification is not allowed.
```

A source search for:

```python
order.status = request_data["status"]
```

returned:

```text
No vulnerable assignment found.
```

### Targeted SAST Verification

The project-specific Semgrep rule reported:

```text
Before remediation:
1 targeted finding

After remediation:
0 targeted findings
```

### Functional Verification

The dedicated return endpoint remained available.

This confirmed that the remediation blocked the vulnerable path without removing the legitimate return functionality.

---

## Defence-in-Depth Recommendations

The implemented HTTP 403 control addresses the confirmed exploit.

The following additional protections are recommended.

### Dedicated Request Models

Use a dedicated serializer or Data Transfer Object containing only permitted client-editable properties.

The protected `status` field should not be part of the general PUT request model.

### Explicit State Machine

Define allowed transitions explicitly:

```text
delivered → return pending
return pending → returned
```

Disallow:

```text
delivered → returned
```

through general client requests.

### Trusted Transition Ownership

Only trusted server-side workflow code should complete:

```text
return pending → returned
```

### Idempotent Refund Logic

Ensure that refund credit can be issued only once.

Repeated requests or duplicate events must not add credit multiple times.

### Transactional Update

Where supported, update final order state and refund credit within one transaction.

This reduces the possibility of inconsistent order and credit data.

### Security Logging

Log rejected status-modification attempts with:

- Authenticated user identifier
- Order identifier
- Requested transition
- Timestamp
- Correlation identifier
- Response result

Do not log:

- Authorization headers
- Bearer tokens
- Session cookies
- Passwords

### Automated Testing

Add tests confirming:

- The general PUT endpoint rejects `returned`.
- The general PUT endpoint rejects `return pending`.
- A client cannot trigger refund credit directly.
- The legitimate return endpoint remains functional.
- Refund credit cannot be issued twice.
- Required workflow states cannot be skipped.

### CI/CD Enforcement

Retain the custom rule:

```text
crapi-client-controlled-order-status
```

The security workflow should fail if direct client-controlled status assignment is reintroduced.

---

## Evidence References

### Architecture and Threat-Modelling Evidence

- `M2_07_Data_Flow_Diagram.png`
- `M2_05_STRIDE_High_Risk_Threats.png`
- `M2_06_Risk_Assessment_Table.png`

### Normal Workflow and Initial Negative Test

- `M2_21_Normal_Request_Redacted.png`
- `M2_22_Normal_Response_Redacted.png`
- `M2_23_Modified_Request_Redacted.png`
- `M2_24_Protected_Response_Redacted.png`
- `M2_25_Protected_Test_Comparison.png`

### Source-Investigation Evidence

- `M2_26_Source_Search_Result.png`
- `M2_26A_Endpoint_Mapping.png`
- `M2_27_Shadow_PUT_Endpoint_Code.png`
- `M2_28_Order_Status_Values.png`

### Exploitation Evidence

- `M2_30_Order_State_Before_Test.png`
- `M2_31_Modified_PUT_Request_Redacted.png`
- `M2_32_Vulnerable_PUT_Response.png`
- `M2_33_Application_State_Before_After.png`

### Remediation Evidence

- `M2_34_Root_Cause_Analysis.png`
- `M2_35_Backup_Created.png`
- `M2_36_Secure_Code_Remediation.png`
- `M2_37_Git_Diff.png`
- `M2_37A_Security_Fix_Commit.png`

### Rebuild and Retest Evidence

- `M2_38_Service_Rebuild.png`
- `M2_38C_Service_Logs.png`
- `M2_39_Order_Before_Retest.png`
- `M2_40_Modified_Request_After_Fix.png`
- `M2_41_Protected_Response.png`
- `M2_42_No_State_Change.png`

### SAST and CI/CD Verification Evidence

- `M2_43_Source_Remediation_Verification.png`
- `M2_44_Custom_Mass_Assignment_Rule.png`
- `M2_45_Custom_Rule_Validation.png`
- `M2_46_Custom_Rule_Before_Fix.png`
- `M2_47_Custom_Rule_After_Fix.png`
- `M2_50_SAST_Before_After_Comparison.png`
- `M2_55_Controlled_SAST_Failure.png`
- `M2_56_SAST_Gate_Passed.png`

---

## Root-Cause Status

### Analysis Status

- **Root cause identified:** Yes
- **Contributing causes identified:** Yes
- **Source-to-impact trace completed:** Yes
- **Business impact demonstrated:** Yes
- **STRIDE mapping completed:** Yes
- **Final DFD mapping completed:** Yes
- **Risk assessment completed:** Yes

### Remediation Status

- **Protected status removed from client control:** Yes
- **HTTP 403 rejection implemented:** Yes
- **Legitimate return workflow retained:** Yes
- **Source change committed:** Yes
- **Workshop service rebuilt:** Yes
- **Remediated implementation deployed:** Yes

### Verification Status

- **Exact exploit repeated:** Yes
- **Exploit blocked:** Yes
- **Order state remained unchanged:** Yes
- **Available credit remained unchanged:** Yes
- **Targeted finding reduced from 1 to 0:** Yes
- **CI/CD recurrence protection implemented:** Yes

---

## Final Root-Cause Statement

The vulnerability was caused by exposing the protected order `status` property through a client-controlled PUT endpoint without enforcing authorization over the requested business-state transition.

The application correctly authenticated the requester, confirmed order ownership, and verified that `returned` was a valid status value.

However, these controls did not authorize the direct transition from `delivered` to `returned`.

The client-controlled request entered the Workshop service through DF6 and crossed TB2. The unauthorized status and refund-credit changes were then persisted through DF11 across TB3 into MongoDB Workshop Data.

Because the refund logic trusted the client-selected final order state, the application issued unauthorized credit.

The root cause was resolved by:

- Removing client control over the protected status property
- Rejecting direct status modification with HTTP 403
- Preserving legitimate transitions inside the dedicated return workflow
- Rebuilding and recreating the Workshop service
- Repeating the exact exploit after remediation
- Confirming no order-state or credit change
- Reducing the targeted Semgrep finding from one to zero
- Enforcing the custom rule in CI/CD before deployment across TB5
