# Source Investigation
 
The API endpoint used during testing was traced through the application source code.
 
The URL route:
 
/workshop/api/shop/orders/{order_id}
 
is mapped to:
 
OrderControlView
 
inside:
 
crAPI/services/workshop/crapi/shop/views.py
 
This class is responsible for processing PUT requests that update order properties.
 
The route mapping was identified in:
 
crAPI/services/workshop/crapi/shop/urls.py
