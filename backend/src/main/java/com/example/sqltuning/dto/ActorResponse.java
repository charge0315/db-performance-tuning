package com.example.sqltuning.dto;

import com.example.sqltuning.entity.Actor;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActorResponse {
    private List<Actor> actors;
    private String executedSql;
    private Long executionTimeMs;
}
