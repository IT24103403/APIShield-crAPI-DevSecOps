# Vulnerable Code Discovery
 
The source code investigation identified a vulnerable order update endpoint.
 
File:
 
crAPI/services/workshop/crapi/shop/views.py
 
Endpoint:
 
PUT /workshop/api/shop/orders/{order_id}
 
The endpoint accepts a client-controlled property:
 
request_data["status"]
 
and immediately updates:
 
order.status
 
If the supplied value equals:
 
returned
 
the backend credits the user's account:
 
user_details.available_credit +=
    order.quantity * order.product.price
 
Because state transitions are not restricted to the intended business process, an authenticated user can modify an order state and obtain a refund without completing the legitimate return workflow.
 
This behavior represents a Mass Assignment / Unsafe Property Update vulnerability.
