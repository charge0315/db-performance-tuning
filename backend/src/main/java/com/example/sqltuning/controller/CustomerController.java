package com.example.sqltuning.controller;

import com.example.sqltuning.dto.CustomerResponse;
import com.example.sqltuning.entity.Customer;
import com.example.sqltuning.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/customers")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:3000")
public class CustomerController {

    private final CustomerService customerService;

    /**
     * 全顧客を取得（遅いバージョン - 過度なJOIN）
     */
    @GetMapping("/slow")
    public ResponseEntity<CustomerResponse> getAllCustomersSlow() {
        return ResponseEntity.ok(customerService.getAllCustomersSlow());
    }

    /**
     * 全顧客を取得（速いバージョン - 最適化済み）
     */
    @GetMapping("/fast")
    public ResponseEntity<CustomerResponse> getAllCustomersFast() {
        return ResponseEntity.ok(customerService.getAllCustomersFast());
    }

    /**
     * メールで顧客を検索
     */
    @GetMapping("/search")
    public ResponseEntity<Customer> getCustomerByEmail(@RequestParam String email) {
        Customer customer = customerService.getCustomerByEmail(email);
        if (customer == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(customer);
    }
}
