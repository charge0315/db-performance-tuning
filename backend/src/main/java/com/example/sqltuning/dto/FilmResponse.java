package com.example.sqltuning.dto;

import com.example.sqltuning.entity.Film;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FilmResponse {
    private List<Film> films;
    private String executedSql;
    private Long executionTimeMs;
    private List<Map<String, Object>> executionPlan;
}
