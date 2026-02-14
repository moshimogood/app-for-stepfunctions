package com.example.order.handler;

import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.example.order.model.OrderContext;

public class PaymentHandler implements RequestHandler<OrderContext, OrderContext> {
    
    @Override
    public OrderContext handleRequest(OrderContext input, com.amazonaws.services.lambda.runtime.Context context) {

        if ("NG".equals(input.orderId)) {
            throw new RuntimeException("Payment failed");
        }

        input.status = "SUCCESS";
        input.message = "Payment OK";

        return input;
    }
    
}
