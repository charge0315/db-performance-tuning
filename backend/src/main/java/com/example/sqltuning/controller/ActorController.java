package com.example.sqltuning.controller;

import com.example.sqltuning.entity.Actor;
import com.example.sqltuning.service.ActorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/actors")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:3000")
public class ActorController {

    private final ActorService actorService;

    @GetMapping
    public ResponseEntity<List<Actor>> getAllActors() {
        return ResponseEntity.ok(actorService.getAllActors());
    }

    @GetMapping("/search")
    public ResponseEntity<List<Actor>> searchActors(@RequestParam String name) {
        return ResponseEntity.ok(actorService.searchActorsByName(name));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Actor> getActorById(@PathVariable Integer id) {
        Actor actor = actorService.getActorById(id);
        if (actor == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(actor);
    }
}
