# Confirmed Mass Assignment Vulnerability
 
## Vulnerability Type
 
Mass Assignment / Unsafe Property Update
 
## Endpoint
 
PUT /workshop/api/shop/orders/{order_id}
 
## Order Tested
 
Order ID: 49
 
## Before Test
 
Status: delivered
 
Available Balance: 40
 
## Modified Request
 
{
    "status": "returned"
}
 
## After Test
 
Status: returned
 
Available Balance: 50
 
## Vulnerability Confirmed
 
The endpoint accepted a client-controlled status property.
 
The application immediately updated the order status to returned and added refund credit to the user account.
 
## Security Impact
 
An authenticated user can bypass the intended return workflow and obtain a refund without completing the required return process.
 
## STRIDE Mapping
 
Tampering
 
## Risk Rating
 
Likelihood: 4
 
Impact: 4
 
Risk Score: 16
 
Rating: High
 
