package com.example.sqltuning;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.example.sqltuning.mapper")
public class SqlTuningDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(SqlTuningDemoApplication.class, args);
    }
}
