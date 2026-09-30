# Root Cause Analysis
 
## Vulnerability
 
Mass Assignment / Unsafe Property Update
 
## Endpoint
 
PUT /workshop/api/shop/orders/{order_id}
 
## Source Location
 
crAPI/services/workshop/crapi/shop/views.py
 
## Vulnerable Code
 
The endpoint accepts a client-controlled status field:
 
order.status = request_data["status"]
 
The backend then evaluates the new state:
 
if request_data["status"] == Order.STATUS_CHOICES.RETURNED.value:
 
and immediately credits the user account:
 
user_details.available_credit += (
    order.quantity * order.product.price
)
 
## Root Cause
 
The application validates that the submitted status belongs to a valid status enumeration.
 
However, the endpoint does not validate whether the user is authorized to perform the requested business-state transition.
 
An authenticated user can therefore move an order directly from:
 
delivered
 
to:
 
returned
 
without completing the intended return workflow.
 
## Business Impact
 
Users can obtain refund credits without physically returning products.
 
This affects:
 
- Order integrity
- Financial integrity
- Business workflow controls
 
## STRIDE Mapping
 
Category:
Tampering
 
Threat:
T3 Unauthorized Field Modification
 
Asset:
Order Records
User Credit Balance
 
Data Flow:
DF4 Authenticated API Request
 
Trust Boundary:
TB2 Web Layer → Backend API
 
## Risk Rating
 
Likelihood: 4
 
Impact: 4
 
Risk Score: 16
 
Classification: High
 
## Evidence
 
M2_27_Shadow_PUT_Endpoint_Code.png
 
M2_28_Order_Status_Values.png
 
M2_30_Order_State_Before_Test.png
 
M2_31_Modified_PUT_Request_Redacted.png
 
M2_32_Vulnerable_PUT_Response.png
 
M2_33_Application_State_Before_After.png
