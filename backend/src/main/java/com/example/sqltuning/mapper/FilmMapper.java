package com.example.sqltuning.mapper;

import com.example.sqltuning.entity.Film;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FilmMapper {

    /**
     * 全映画を取得（インデックス未使用 - 遅い）
     */
    List<Film> findAllFilms();

    /**
     * タイトルで映画を検索（インデックス未使用 - 遅い）
     * LIKEをテーブルスキャンで実行
     */
    List<Film> findFilmsByTitleSlow(@Param("title") String title);

    /**
     * タイトルで映画を検索（インデックス使用 - 速い）
     */
    List<Film> findFilmsByTitleFast(@Param("title") String title);

    /**
     * 映画と言語情報を取得（N+1問題あり - 遅い）
     */
    List<Film> findFilmsWithLanguageSlow();

    /**
     * 映画と言語情報を取得（JOIN使用 - 速い）
     */
    List<Film> findFilmsWithLanguageFast();

    /**
     * 複雑な条件での検索（サブクエリ多用 - 遅い）
     */
    List<Film> findFilmsComplexSlow(@Param("minLength") Integer minLength);

    /**
     * 複雑な条件での検索（最適化済み - 速い）
     */
    List<Film> findFilmsComplexFast(@Param("minLength") Integer minLength);

    /**
     * IDで映画を取得
     */
    Film findFilmById(@Param("filmId") Integer filmId);
}
