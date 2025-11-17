package com.example.sqltuning.dto;

import com.example.sqltuning.entity.Customer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CustomerResponse {
    private List<Customer> customers;
    private String executedSql;
    private Long executionTimeMs;
}
