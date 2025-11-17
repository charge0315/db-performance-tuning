package com.example.sqltuning.service;

import com.example.sqltuning.dto.FilmResponse;
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

    public FilmResponse searchFilmsByTitleSlow(String title) {
        String sql = String.format(
            "SELECT film_id, title, description, release_year, language_id,\n" +
            "       original_language_id, rental_duration, rental_rate, length,\n" +
            "       replacement_cost, rating, special_features, last_update\n" +
            "FROM film\n" +
            "WHERE title LIKE '%%%s%%'\n" +
            "ORDER BY title", title);
        
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsByTitleSlow(title);
        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;
        
        log.info("searchFilmsByTitleSlow実行時間: {}ms, 検索語: {}, 取得件数: {}",
                executionTime, title, films.size());
        return new FilmResponse(films, sql, executionTime);
    }

    public FilmResponse searchFilmsByTitleFast(String title) {
        String sql = String.format(
            "SELECT film_id, title, description, release_year, language_id,\n" +
            "       original_language_id, rental_duration, rental_rate, length,\n" +
            "       replacement_cost, rating, special_features, last_update\n" +
            "FROM film\n" +
            "WHERE title LIKE '%s%%'\n" +
            "ORDER BY title", title);
        
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsByTitleFast(title);
        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;
        
        log.info("searchFilmsByTitleFast実行時間: {}ms, 検索語: {}, 取得件数: {}",
                executionTime, title, films.size());
        return new FilmResponse(films, sql, executionTime);
    }

    public FilmResponse getFilmsWithLanguageSlow() {
        String sql = 
            "SELECT film_id, title, description, release_year, language_id,\n" +
            "       original_language_id, rental_duration, rental_rate, length,\n" +
            "       replacement_cost, rating, special_features, last_update\n" +
            "FROM film\n" +
            "LIMIT 100";
        
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsWithLanguageSlow();
        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;
        
        log.info("getFilmsWithLanguageSlow実行時間: {}ms, 取得件数: {}",
                executionTime, films.size());
        return new FilmResponse(films, sql, executionTime);
    }

    public FilmResponse getFilmsWithLanguageFast() {
        String sql = 
            "SELECT f.film_id, f.title, f.description, f.release_year, f.language_id,\n" +
            "       f.original_language_id, f.rental_duration, f.rental_rate, f.length,\n" +
            "       f.replacement_cost, f.rating, f.special_features, f.last_update,\n" +
            "       l.name as language_name\n" +
            "FROM film f\n" +
            "INNER JOIN language l ON f.language_id = l.language_id\n" +
            "LIMIT 100";
        
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsWithLanguageFast();
        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;
        
        log.info("getFilmsWithLanguageFast実行時間: {}ms, 取得件数: {}",
                executionTime, films.size());
        return new FilmResponse(films, sql, executionTime);
    }

    public FilmResponse getFilmsComplexSlow(Integer minLength) {
        String sql = String.format(
            "SELECT f.film_id, f.title, f.description, f.release_year, f.language_id,\n" +
            "       f.original_language_id, f.rental_duration, f.rental_rate, f.length,\n" +
            "       f.replacement_cost, f.rating, f.special_features, f.last_update,\n" +
            "       (SELECT l.name FROM language l WHERE l.language_id = f.language_id) as language_name,\n" +
            "       (SELECT COUNT(*) FROM film_actor fa WHERE fa.film_id = f.film_id) as actor_count\n" +
            "FROM film f\n" +
            "WHERE f.length >= %d\n" +
            "AND EXISTS (\n" +
            "    SELECT 1 FROM film_actor fa2\n" +
            "    WHERE fa2.film_id = f.film_id\n" +
            ")\n" +
            "ORDER BY f.title\n" +
            "LIMIT 50", minLength);
        
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsComplexSlow(minLength);
        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;
        
        log.info("getFilmsComplexSlow実行時間: {}ms, 最小長: {}, 取得件数: {}",
                executionTime, minLength, films.size());
        return new FilmResponse(films, sql, executionTime);
    }

    public FilmResponse getFilmsComplexFast(Integer minLength) {
        String sql = String.format(
            "SELECT f.film_id, f.title, f.description, f.release_year, f.language_id,\n" +
            "       f.original_language_id, f.rental_duration, f.rental_rate, f.length,\n" +
            "       f.replacement_cost, f.rating, f.special_features, f.last_update,\n" +
            "       l.name as language_name,\n" +
            "       COUNT(DISTINCT fa.actor_id) as actor_count\n" +
            "FROM film f\n" +
            "INNER JOIN language l ON f.language_id = l.language_id\n" +
            "INNER JOIN film_actor fa ON f.film_id = fa.film_id\n" +
            "WHERE f.length >= %d\n" +
            "GROUP BY f.film_id, f.title, f.description, f.release_year, f.language_id,\n" +
            "         f.original_language_id, f.rental_duration, f.rental_rate, f.length,\n" +
            "         f.replacement_cost, f.rating, f.special_features, f.last_update,\n" +
            "         l.name\n" +
            "ORDER BY f.title\n" +
            "LIMIT 50", minLength);
        
        long startTime = System.currentTimeMillis();
        List<Film> films = filmMapper.findFilmsComplexFast(minLength);
        long endTime = System.currentTimeMillis();
        long executionTime = endTime - startTime;
        
        log.info("getFilmsComplexFast実行時間: {}ms, 最小長: {}, 取得件数: {}",
                executionTime, minLength, films.size());
        return new FilmResponse(films, sql, executionTime);
    }

    public Film getFilmById(Integer filmId) {
        return filmMapper.findFilmById(filmId);
    }
}
