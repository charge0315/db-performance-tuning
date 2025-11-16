package com.example.sqltuning.service;

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

    public List<Customer> getAllCustomersSlow() {
        long startTime = System.currentTimeMillis();
        List<Customer> customers = customerMapper.findAllCustomersSlow();
        long endTime = System.currentTimeMillis();
        log.info("getAllCustomersSlow実行時間: {}ms, 取得件数: {}",
                (endTime - startTime), customers.size());
        return customers;
    }

    public List<Customer> getAllCustomersFast() {
        long startTime = System.currentTimeMillis();
        List<Customer> customers = customerMapper.findAllCustomersFast();
        long endTime = System.currentTimeMillis();
        log.info("getAllCustomersFast実行時間: {}ms, 取得件数: {}",
                (endTime - startTime), customers.size());
        return customers;
    }

    public Customer getCustomerByEmail(String email) {
        return customerMapper.findCustomerByEmail(email);
    }
}
