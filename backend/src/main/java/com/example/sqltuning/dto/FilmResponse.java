package com.example.sqltuning.dto;

import com.example.sqltuning.entity.Film;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FilmResponse {
    private List<Film> films;
    private String executedSql;
    private Long executionTimeMs;
}
