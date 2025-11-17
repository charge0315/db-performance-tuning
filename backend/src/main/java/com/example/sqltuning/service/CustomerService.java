package com.example.sqltuning.service;

import com.example.sqltuning.dto.CustomerResponse;
import com.example.sqltuning.entity.Customer;
import com.example.sqltuning.mapper.CustomerMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class CustomerService {

    private final CustomerMapper customerMapper;

    public CustomerResponse getAllCustomersSlow() {
        String sql = 
            "SELECT customer_id, first_name, last_name, email,\n" +
            "       active, create_date, last_update\n" +
            "FROM customer\n" +
            "ORDER BY customer_id\n" +
            "LIMIT 100";
        
        long startTime = System.currentTimeMillis();
        List<Customer> customers = customerMapper.findAllCustomersSlow();
        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;
        
        log.info("getAllCustomersSlow実行時間: {}ms, 取得件数: {}",
                executionTime, customers.size());
        return new CustomerResponse(customers, sql, executionTime);
    }

    public CustomerResponse getAllCustomersFast() {
        String sql = 
            "SELECT customer_id, first_name, last_name, email,\n" +
            "       active, create_date, last_update\n" +
            "FROM customer\n" +
            "WHERE active = 1\n" +
            "ORDER BY customer_id\n" +
            "LIMIT 100";
        
        long startTime = System.currentTimeMillis();
        List<Customer> customers = customerMapper.findAllCustomersFast();
        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;
        
        log.info("getAllCustomersFast実行時間: {}ms, 取得件数: {}",
                executionTime, customers.size());
        return new CustomerResponse(customers, sql, executionTime);
    }

    public Customer getCustomerByEmail(String email) {
        return customerMapper.findCustomerByEmail(email);
    }
}
