package com.example.sqltuning.mapper;

import com.example.sqltuning.entity.Actor;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ActorMapper {

    /**
     * 全俳優を取得
     */
    List<Actor> findAllActors();

    /**
     * 名前で俳優を検索
     */
    List<Actor> findActorsByName(@Param("name") String name);

    /**
     * IDで俳優を取得
     */
    Actor findActorById(@Param("actorId") Integer actorId);
}
