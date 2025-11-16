package com.example.sqltuning.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Actor {
    private Integer actorId;
    private String firstName;
    private String lastName;
    private LocalDateTime lastUpdate;
}
