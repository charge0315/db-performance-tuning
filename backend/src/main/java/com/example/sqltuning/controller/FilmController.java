package com.example.sqltuning.controller;

import com.example.sqltuning.dto.FilmResponse;
import com.example.sqltuning.entity.Film;
import com.example.sqltuning.service.FilmService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/films")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:3000")
public class FilmController {

    private final FilmService filmService;

    /**
     * 全映画を取得
     */
    @GetMapping
    public ResponseEntity<List<Film>> getAllFilms() {
        return ResponseEntity.ok(filmService.getAllFilms());
    }

    /**
     * タイトルで検索（遅いバージョン - インデックス未使用）
     */
    @GetMapping("/search/slow")
    public ResponseEntity<FilmResponse> searchFilmsSlow(@RequestParam String title) {
        return ResponseEntity.ok(filmService.searchFilmsByTitleSlow(title));
    }

    /**
     * タイトルで検索（速いバージョン - インデックス使用）
     */
    @GetMapping("/search/fast")
    public ResponseEntity<FilmResponse> searchFilmsFast(@RequestParam String title) {
        return ResponseEntity.ok(filmService.searchFilmsByTitleFast(title));
    }

    /**
     * 言語情報付き映画取得（遅いバージョン - N+1問題）
     */
    @GetMapping("/with-language/slow")
    public ResponseEntity<FilmResponse> getFilmsWithLanguageSlow() {
        return ResponseEntity.ok(filmService.getFilmsWithLanguageSlow());
    }

    /**
     * 言語情報付き映画取得（速いバージョン - JOIN使用）
     */
    @GetMapping("/with-language/fast")
    public ResponseEntity<FilmResponse> getFilmsWithLanguageFast() {
        return ResponseEntity.ok(filmService.getFilmsWithLanguageFast());
    }

    /**
     * 複雑な条件での検索（遅いバージョン - サブクエリ多用）
     */
    @GetMapping("/complex/slow")
    public ResponseEntity<FilmResponse> getFilmsComplexSlow(@RequestParam(defaultValue = "90") Integer minLength) {
        return ResponseEntity.ok(filmService.getFilmsComplexSlow(minLength));
    }

    /**
     * 複雑な条件での検索（速いバージョン - 最適化済み）
     */
    @GetMapping("/complex/fast")
    public ResponseEntity<FilmResponse> getFilmsComplexFast(@RequestParam(defaultValue = "90") Integer minLength) {
        return ResponseEntity.ok(filmService.getFilmsComplexFast(minLength));
    }

    /**
     * IDで映画を取得
     */
    @GetMapping("/{id}")
    public ResponseEntity<Film> getFilmById(@PathVariable Integer id) {
        Film film = filmService.getFilmById(id);
        if (film == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(film);
    }
}
