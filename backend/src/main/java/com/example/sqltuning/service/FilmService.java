package com.example.sqltuning.service;

import com.example.sqltuning.entity.Film;
import com.example.sqltuning.mapper.FilmMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class FilmService {

    private final FilmMapper filmMapper;

    public List<Film> getAllFilms() {
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findAllFilms();
        long endTime = System.currentTimeMillis();
        log.info("getAllFilms実行時間: {}ms, 取得件数: {}", (endTime - startTime), films.size());
        return films;
    }

    public List<Film> searchFilmsByTitleSlow(String title) {
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsByTitleSlow(title);
        long endTime = System.currentTimeMillis();
        log.info("searchFilmsByTitleSlow実行時間: {}ms, 検索語: {}, 取得件数: {}",
                (endTime - startTime), title, films.size());
        return films;
    }

    public List<Film> searchFilmsByTitleFast(String title) {
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsByTitleFast(title);
        long endTime = System.currentTimeMillis();
        log.info("searchFilmsByTitleFast実行時間: {}ms, 検索語: {}, 取得件数: {}",
                (endTime - startTime), title, films.size());
        return films;
    }

    public List<Film> getFilmsWithLanguageSlow() {
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsWithLanguageSlow();
        long endTime = System.currentTimeMillis();
        log.info("getFilmsWithLanguageSlow実行時間: {}ms, 取得件数: {}",
                (endTime - startTime), films.size());
        return films;
    }

    public List<Film> getFilmsWithLanguageFast() {
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsWithLanguageFast();
        long endTime = System.currentTimeMillis();
        log.info("getFilmsWithLanguageFast実行時間: {}ms, 取得件数: {}",
                (endTime - startTime), films.size());
        return films;
    }

    public List<Film> getFilmsComplexSlow(Integer minLength) {
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsComplexSlow(minLength);
        long endTime = System.currentTimeMillis();
        log.info("getFilmsComplexSlow実行時間: {}ms, 最小長: {}, 取得件数: {}",
                (endTime - startTime), minLength, films.size());
        return films;
    }

    public List<Film> getFilmsComplexFast(Integer minLength) {
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsComplexFast(minLength);
        long endTime = System.currentTimeMillis();
        log.info("getFilmsComplexFast実行時間: {}ms, 最小長: {}, 取得件数: {}",
                (endTime - startTime), minLength, films.size());
        return films;
    }

    public Film getFilmById(Integer filmId) {
        return filmMapper.findFilmById(filmId);
    }
}
