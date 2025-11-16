package com.example.sqltuning.controller;

import com.example.sqltuning.dto.LoginRequest;
import com.example.sqltuning.dto.LoginResponse;
import com.example.sqltuning.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:3000")
@Slf4j
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            log.info("ログイン試行: {}", loginRequest.getUsername());

            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()
                    )
            );

            String token = jwtTokenProvider.generateToken(authentication);

            log.info("ログイン成功: {}", loginRequest.getUsername());
            return ResponseEntity.ok(new LoginResponse(
                    token,
                    loginRequest.getUsername(),
                    "ログインに成功しました"
            ));

        } catch (AuthenticationException e) {
            log.error("ログイン失敗: {}", loginRequest.getUsername());
            return ResponseEntity.badRequest().body(
                    new LoginResponse(null, null, "ユーザー名またはパスワードが正しくありません")
            );
        }
    }

    @GetMapping("/test")
    public ResponseEntity<String> test() {
        return ResponseEntity.ok("認証APIは正常に動作しています");
    }
}
