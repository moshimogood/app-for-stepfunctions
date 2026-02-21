package com.example.order.handler;

import java.util.List;
import java.util.Map;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class InventoryAggregateHandler implements RequestHandler<Map<String, Object>, Map<String, Object>> {
    
    @Override
    public Map<String, Object> handleRequest(Map<String, Object> input, Context context) {
        
        List<Map<String, Object>> results = (List<Map<String, Object>>) input.get("inventoryResults");
    
        boolean allInStock = true;

        for (Map<String, Object> result : results) {
            boolean inStock = (boolean) result.get("inStock");
            if (!inStock) {
                allInStock = false;
                break;
            }
        }
        input.put("allInStock", allInStock);
        return input;
    }
    
}
