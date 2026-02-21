package com.example.order.handler;

import java.util.Map;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class ItemInventoryHandler implements RequestHandler<Map<String, Object>, Map<String, Object>> {
    
    @Override
    public Map<String, Object> handleRequest(Map<String, Object> input, Context context) {
        
        boolean inStock = !"NG".equals(input.get("itemId"));
        
        input.put("inStock", inStock);
        return input;
    }
}
