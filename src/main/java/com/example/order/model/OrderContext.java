package com.example.order.model;

import java.util.List;
import java.util.Map;

public class OrderContext {
    public String orderId;
    public String status;
    public String message;
    public List<Map<String, Object>> items;
}
