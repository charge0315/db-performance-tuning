package com.example.sqltuning.mapper;

import com.example.sqltuning.entity.Customer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CustomerMapper {

    /**
     * 全顧客を取得（JOIN多用 - 遅い可能性あり）
     */
    List<Customer> findAllCustomersSlow();

    /**
     * 全顧客を取得（最適化済み）
     */
    List<Customer> findAllCustomersFast();

    /**
     * メールで顧客を検索
     */
    Customer findCustomerByEmail(@Param("email") String email);
}
