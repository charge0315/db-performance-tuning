package com.example.sqltuning.mapper;

import com.example.sqltuning.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {

    /**
     * ユーザー名でユーザーを検索
     */
    User findByUsername(@Param("username") String username);

    /**
     * ユーザーを作成
     */
    int insertUser(User user);
}
