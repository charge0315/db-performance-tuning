package com.example.sqltuning.service;

import com.example.sqltuning.entity.Actor;
import com.example.sqltuning.mapper.ActorMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ActorService {

    private final ActorMapper actorMapper;

    public List<Actor> getAllActors() {
        long startTime = System.currentTimeMillis();
        List<Actor> actors = actorMapper.findAllActors();
        long endTime = System.currentTimeMillis();
        log.info("getAllActors実行時間: {}ms, 取得件数: {}", (endTime - startTime), actors.size());
        return actors;
    }

    public List<Actor> searchActorsByName(String name) {
        long startTime = System.currentTimeMillis();
        List<Actor> actors = actorMapper.findActorsByName(name);
        long endTime = System.currentTimeMillis();
        log.info("searchActorsByName実行時間: {}ms, 検索語: {}, 取得件数: {}",
                (endTime - startTime), name, actors.size());
        return actors;
    }

    public Actor getActorById(Integer actorId) {
        return actorMapper.findActorById(actorId);
    }
}
