# V-02: Mass Assignment
 
## Scope
 
The assessment was performed exclusively against the locally controlled
OWASP crAPI educational environment hosted for the university project.
 
## Affected component
 
Add the confirmed service name.
 
## Endpoint
 
Add the HTTP method and path. Redact user identifiers and tokens.
 
## Normal behaviour
 
Explain the expected order or object-update workflow.
 
## Security test
 
Explain that an unexpected client-controlled field was introduced into
a request to determine whether server-managed state was protected.
 
## Observed behaviour
 
State exactly what happened. Do not exaggerate the result.
 
## STRIDE mapping
 
- Category: Tampering
- Threat: T3 Unauthorized field modification
- Asset: Relevant business or order record
- Trust boundary: TB2 Web to Backend API
- Data flow: DF4 Authenticated API request
 
## Root cause hypothesis
 
The server may be binding client-provided properties to an internal
object without a sufficiently restrictive request model or allowlist.
 
## Likelihood
 
4 - Likely
 
Justification:
The operation is available to an authenticated user and can be tested
through ordinary API requests.
 
## Impact
 
4 - Major
 
Justification:
Unauthorized modification of server-managed business state may affect
record integrity and the correctness of business transactions.
 
## Risk score
 
4 × 4 = 16, High
 
## Evidence
 
- M2_21 Normal request
- M2_22 Normal response
- M2_23 Modified request
- M2_24 Vulnerable response
- M2_25 Application state comparison
 
## Recommended remediation
 
- Use a dedicated request DTO.
- Allowlist client-editable fields.
- Reject unexpected fields.
- Validate numeric ranges and permitted states.
- Obtain protected values from trusted server-side context.
- Add a negative automated test.
 
## Limitations
 
Document any behaviour that was not confirmed through both runtime
testing and source-code review.





##########
 
HTTP Method:
POST
 
API Path:
/workshop/api/shop/orders
 
Legitimate Request Fields:
product_id
quantity
 
Unexpected Field Tested:
credit
 
Original Status Code:
200
 
Modified Status Code:
200
 
Observed State Change:
The server processed the request successfully, but the injected field was not reflected in the response.
 
Behaviour Persisted:
No evidence that the injected field affected application state.
 
Only Laboratory Record Affected:
Yes
 
Conclusion:
The backend appears to ignore or override the client-supplied credit value. Based on the observed behaviour, no mass-assignment condition was confirmed for the tested property.





## Root Cause Analysis
 
The source code for the endpoint
`/workshop/api/shop/orders`
was identified in:
 
crAPI/services/workshop/crapi/shop/views.py
 
Review of the POST request handler showed that the endpoint validates incoming user input using:
 
ProductQuantitySerializer
 
Only the fields:
 
- product_id
- quantity
 
are processed when creating a new order.
 
The injected field:
 
credit
 
was not referenced within the order creation logic.
 
As a result, the server ignored the unexpected property and continued to generate the credit value using backend business logic.
 
Based on source-code review and response analysis, no mass-assignment vulnerability was confirmed for the tested parameter.
