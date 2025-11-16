package com.example.sqltuning.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Customer {
    private Integer customerId;
    private Integer storeId;
    private String firstName;
    private String lastName;
    private String email;
    private Integer addressId;
    private Boolean active;
    private LocalDateTime createDate;
    private LocalDateTime lastUpdate;

    // Join用の追加フィールド
    private String address;
    private String city;
    private String country;
}
