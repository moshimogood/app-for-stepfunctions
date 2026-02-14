package com.example.order.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.example.order.model.OrderContext;

public class NotifyHandler implements RequestHandler<OrderContext, OrderContext> {
    
    @Override
    public OrderContext handleRequest(OrderContext input, Context context) {

        input.status = "SUCCESS";
        input.message = "Notification sent";

        return input;
    }
}
