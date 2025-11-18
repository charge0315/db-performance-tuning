# SQLパフォーマンスチューニング デモアプリケーション

## 📝 概要

このプロジェクトは、**SQLパフォーマンスチューニング**の講義で使用するデモアプリケーションです。
MySQLのサンプルデータベース「Sakila」を使用して、以下のパフォーマンスチューニング技術を実践的に学習できます。

### 学習できる内容

1. **インデックスの重要性**
   - インデックスありとなしの性能差（動的なインデックス作成・削除機能付き）
   - 前方一致検索でのインデックス利用
   - LIKE中間一致(%keyword%)とフルテーブルスキャンの性能差
   - 実行計画（EXPLAIN）のリアルタイム表示

2. **JOINの最適化（N+1問題の実演）**
   - **N+1問題の実装例とコード解説**：
     - 100件のfilmデータを取得後、各filmに対してループで個別にlanguageテーブルを検索（101回のDBクエリ）
     - Javaコードのシンタックスハイライト付き表示
   - JOINを使った最適化（1回のクエリで完結）
   - 実行時間の比較とクエリ実行回数の可視化

3. **サブクエリの最適化**
   - 相関サブクエリの問題点（スカラーサブクエリとEXISTS句の性能問題）
   - JOINとGROUP BYへの書き換え
   - 実行計画の比較

4. **実行計画の可視化**
   - EXPLAIN結果のシンタックスハイライト表示
   - type（ALL, index, ref, eq_ref等）の色分け
   - rows（スキャン行数）の警告表示
   - 使用されたインデックス（key）の強調表示
   - Extra情報（Using filesort, Using temporary等）の判別

---

## 🏗️ アーキテクチャ

### 技術スタック

**バックエンド:**

- Java 21 (Microsoft OpenJDK)
- Spring Boot 3.2.0
- Spring Security + JWT認証
- MyBatis 3.0.3
- MySQL 8.0

**フロントエンド:**

- React 18.2.0
- React Router 6.20.0
- Axios 1.6.2

**インフラ:**

- Docker & Docker Compose

**データベース:**

- MySQL 8.0
- Sakilaサンプルデータベース
- 100,000件のfilmレコード（拡張済み）

### プロジェクト構成

```
db-performance-tuning/
├── backend/                          # Spring Bootバックエンド
│   ├── src/main/java/com/example/sqltuning/
│   │   ├── config/                  # 設定クラス
│   │   ├── controller/              # RESTコントローラー
│   │   ├── dto/                     # データ転送オブジェクト
│   │   ├── entity/                  # エンティティクラス
│   │   ├── mapper/                  # MyBatisマッパーインターフェース
│   │   ├── security/                # セキュリティ設定
│   │   └── service/                 # ビジネスロジック
│   ├── src/main/resources/
│   │   ├── mapper/                  # MyBatis XMLマッパー
│   │   └── application.yml          # アプリケーション設定
│   └── pom.xml                      # Maven設定
│
├── frontend/                        # Reactフロントエンド
│   ├── public/
│   ├── src/
│   │   ├── components/              # Reactコンポーネント
│   │   └── services/                # API通信サービス
│   └── package.json
│
├── database/                        # データベース関連
│   └── scripts/
│       ├── 01-init-sakila.sql      # Sakilaデータベース初期化
│       ├── 02-create-indexes.sql   # インデックス作成
│       └── 03-demo-queries.sql     # デモ用クエリ集
│
├── docker-compose.yml               # Docker Compose設定
└── README.md                        # このファイル
```

---

## 🚀 セットアップ手順

### 前提条件

以下のソフトウェアがインストールされていることを確認してください：

- Docker Desktop (最新版)
- Java 17以上
- Maven 3.6以上
- Node.js 16以上
- npm または yarn

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd db-performance-tuning
```

### 2. 簡単起動（PowerShellスクリプト）

**Windowsユーザー向け：**

プロジェクトルートに用意されたPowerShellスクリプトで簡単に起動できます：

```powershell
# すべて起動（Docker + バックエンド + フロントエンド）
.\start-all.ps1

# すべて停止
.\stop-all.ps1

# バックエンドのみ再起動
.\restart-backend.ps1
```

`start-all.ps1`は以下を自動で実行します：
1. MySQLコンテナの起動と起動確認
2. バックエンド（Spring Boot）のビルドと起動
3. フロントエンド（React）の起動
4. 各サービスの起動確認

起動完了後、以下のURLでアクセスできます：
- **フロントエンド**: http://localhost:3000
- **バックエンドAPI**: http://localhost:8080/api
- **MySQL**: localhost:3306

### 3. 手動セットアップ（詳細手順）

#### 3-1. MySQLデータベースの起動（Docker）

```bash
# Docker Composeでデータベースを起動
docker-compose up -d

# ログを確認（初期化が完了するまで待つ）
docker-compose logs -f mysql

# データベースが起動したことを確認
docker ps
```

**注意:** 初回起動時は、Sakilaデータベースの初期化に数分かかる場合があります。
`database/scripts/` 内のSQLスクリプトが自動的に実行されます。

#### 3-2. データベース接続の確認

```bash
# MySQLコンテナに接続
docker exec -it sql-tuning-mysql mysql -uroot -ppassword

# データベースとテーブルの確認
mysql> USE sakila;
mysql> SHOW TABLES;
mysql> SELECT COUNT(*) FROM film;  -- 1000件のデータがあることを確認
mysql> SELECT COUNT(*) FROM actor; -- 200件のデータがあることを確認
mysql> SELECT COUNT(*) FROM customer; -- 3件のテストデータがあることを確認
mysql> SELECT * FROM users; -- demo, admin, user アカウントを確認
mysql> exit
```

#### 3-3. バックエンド（Spring Boot）の起動

```powershell
# backendディレクトリに移動
cd backend

# Mavenでビルド（テストをスキップ）
mvn clean package -DskipTests

# JARファイルを実行（PowerShellの場合）
Start-Process -NoNewWindow powershell -ArgumentList "java -jar $PWD\target\sql-tuning-demo-1.0.0.jar"

# または、Bashの場合
# java -jar target/sql-tuning-demo-1.0.0.jar
```

**確認:** ブラウザで `http://localhost:8080/api/auth/test` にアクセスして、
「認証APIは正常に動作しています」と表示されることを確認。

#### 3-4. APIテストスクリプトの実行（オプション）

プロジェクトルートに戻り、PowerShellでAPIテストスクリプトを実行できます：

```powershell
# プロジェクトルートに戻る
cd ..

# テストスクリプトを実行
.\test-apis.ps1
```

このスクリプトは以下をテストします：
- 認証テストエンドポイント
- ログイン機能（demo/passwordで認証）
- 俳優エンドポイント（ページネーション付き）
- 映画エンドポイント（ページネーション付き）
- 顧客エンドポイント（最適化版）

#### 3-5. フロントエンド（React）の起動

別のターミナルウィンドウで：

```bash
# frontendディレクトリに移動
cd frontend

# 依存関係をインストール
npm install

# 開発サーバーを起動
npm start
```

**確認:** ブラウザが自動的に開き、`http://localhost:3000` でログイン画面が表示されます。

**注意:** バックエンドが先に起動している必要があります。

---

## 🔧 管理スクリプト

プロジェクトには以下の管理用スクリプトが含まれています：

### PowerShellスクリプト（Windows）

| スクリプト | 説明 |
|-----------|------|
| `start-all.ps1` | Docker、バックエンド、フロントエンドをすべて起動 |
| `stop-all.ps1` | すべてのサービスを停止 |
| `restart-backend.ps1` | バックエンドのみ再起動 |
| `test-apis.ps1` | 全APIエンドポイントをテスト |

**使用例:**

```powershell
# フルスタック起動
.\start-all.ps1

# バックエンドのコード変更後
.\restart-backend.ps1

# APIの動作確認
.\test-apis.ps1

# 終了時
.\stop-all.ps1
```

---

## 🎮 使い方

### ログイン

デモ用のアカウントでログインします：

**一般ユーザー:**
- **ユーザー名:** `demo`
- **パスワード:** `password`

**管理者:**
- **ユーザー名:** `admin`
- **パスワード:** `password`

**その他のユーザー:**
- **ユーザー名:** `user`
- **パスワード:** `password`

### JWT認証について

このアプリケーションはJWT（JSON Web Token）認証を使用しています：
- ログイン成功後、JWTトークンが発行されます
- トークンの有効期限は24時間です
- 保護されたエンドポイントには`Authorization: Bearer <token>`ヘッダーが必要です

### デモの実行

ログイン後、ダッシュボードが表示されます。以下のデモを実行できます：

#### デモ1: インデックスの重要性

**動的インデックス管理機能:**

1. 「インデックスを作成」ボタンをクリック → `film.title`にインデックス`idx_film_title`が作成されます
2. 検索ボックスに「ACADEMY」と入力
3. 「タイトル検索（速い - インデックス利用）」ボタンをクリック → 実行時間とEXPLAIN結果を確認
4. 「インデックスを削除」ボタンをクリック → インデックスが削除されます
5. 「タイトル検索（遅い - LIKE '%keyword%'）」ボタンをクリック → フルテーブルスキャンの実行時間を確認

**学習ポイント:**

- インデックスがある場合: `type: ref` または `type: index` → 高速
- インデックスがない場合: `type: ALL` → フルテーブルスキャン（遅い）
- 実行計画（EXPLAIN）の`type`, `key`, `rows`フィールドの意味
- 100,000件のレコードに対する性能差を体感

#### デモ2: JOINの最適化（N+1問題）

**N+1問題の実装コード（Javaシンタックスハイライト表示）:**

```java
// まずfilmデータを取得
List<Film> films = filmMapper.findFilmsWithLanguageSlow();

// N+1問題: 各filmに対してlanguage名を個別に取得
for (Film film : films) {
    String languageName = filmMapper.findLanguageNameById(film.getLanguageId());
    film.setLanguageName(languageName);
}
```

**デモ手順:**

1. 「言語情報付き取得（遅い - N+1問題）」ボタンをクリック
   - 101回のDBクエリが実行される（1回の初期クエリ + 100回のループクエリ）
   - ログに「クエリ実行回数: 101回」と表示される
2. 「言語情報付き取得（速い - JOIN使用）」ボタンをクリック
   - 1回のJOINクエリで完結
3. 実行時間とクエリ実行回数を比較

**学習ポイント:**

- N+1問題は初心者が陥りやすいパフォーマンス問題
- ループ内でのDB問合せは避けるべき
- JOINを使えば1回のクエリで済む
- 実際のJavaコードを見て理解を深める

#### デモ3: サブクエリの最適化

1. 「複雑な検索（遅い）」ボタンをクリック
2. 「複雑な検索（速い）」ボタンをクリック
3. 実行時間の差を比較

**解説:**

- 遅いバージョン: スカラーサブクエリとEXISTS句を多用
- 速いバージョン: JOINとGROUP BYで最適化
- EXPLAIN結果で`Using temporary`, `Using filesort`の有無を確認

#### デモ4: 過度なJOINの削減

「顧客（Customers）」タブに切り替えて：

1. 「顧客取得（遅い）」ボタンをクリック
2. 「顧客取得（速い）」ボタンをクリック
3. 実行時間の差を比較

**解説:**
- 遅いバージョン: 4つのテーブルをJOIN（address, city, country）
- 速いバージョン: 必要最小限の情報のみ取得

---

## 📊 MyBatisの活用方法

このプロジェクトでは、MyBatisを使用してSQLマッピングを行っています。

### MyBatisマッパーの構成

#### 1. マッパーインターフェース

`backend/src/main/java/com/example/sqltuning/mapper/FilmMapper.java`

```java
@Mapper
public interface FilmMapper {
    List<Film> findFilmsByTitleSlow(@Param("title") String title);
    List<Film> findFilmsByTitleFast(@Param("title") String title);
}
```

#### 2. XMLマッパー

`backend/src/main/resources/mapper/FilmMapper.xml`

```xml
<mapper namespace="com.example.sqltuning.mapper.FilmMapper">
    <!-- 遅いクエリ -->
    <select id="findFilmsByTitleSlow" resultMap="FilmResultMap">
        SELECT * FROM film
        WHERE title LIKE CONCAT('%', #{title}, '%')
    </select>

    <!-- 速いクエリ -->
    <select id="findFilmsByTitleFast" resultMap="FilmResultMap">
        SELECT * FROM film
        WHERE title LIKE CONCAT(#{title}, '%')
    </select>
</mapper>
```

### MyBatisの設定

`backend/src/main/resources/application.yml`

```yaml
mybatis:
  mapper-locations: classpath:mapper/*.xml
  type-aliases-package: com.example.sqltuning.entity
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

**重要な設定:**
- `map-underscore-to-camel-case: true` - snake_caseからcamelCaseへの自動変換
- `log-impl` - SQLログの出力（デバッグ用）

---

## 📈 大規模データによるパフォーマンステスト

### データベースの拡張

プロジェクトには、大規模データでのパフォーマンステストを行うためのSQLスクリプトが含まれています。

#### データ拡張スクリプト

| スクリプト | 説明 | 実行前 | 実行後 |
|-----------|------|--------|--------|
| `04-increase-film-data.sql` | 実在の洋画タイトルをモデルにFilmデータを生成 | 1,000件 | 100,000件 |
| `05-expand-film-id-type.sql` | film_idをSMALLINTからINTに拡張 | - | 最大42億件対応 |
| `07-increase-actor-data.sql` | 実在の俳優名をモデルにActorデータを生成 | 200件 | 20,000件 |
| `08-increase-customer-data.sql` | 実在の人物名をモデルにCustomerデータを生成 | 3件 | 300件 |

#### 実行方法

```powershell
# Film データを100倍に増やす（実在の洋画タイトルを使用）
docker cp .\database\scripts\04-increase-film-data.sql sql-tuning-mysql:/tmp/
docker exec sql-tuning-mysql mysql -uroot -ppassword sakila -e "source /tmp/04-increase-film-data.sql"

# Actor データを100倍に増やす（Tom Cruise, Brad Pittなど実在の俳優名を使用）
docker cp .\database\scripts\07-increase-actor-data.sql sql-tuning-mysql:/tmp/
docker exec sql-tuning-mysql mysql -uroot -ppassword sakila -e "source /tmp/07-increase-actor-data.sql"

# Customer データを100倍に増やす（一般的な英語圏の姓名を使用）
docker cp .\database\scripts\08-increase-customer-data.sql sql-tuning-mysql:/tmp/
docker exec sql-tuning-mysql mysql -uroot -ppassword sakila -e "source /tmp/08-increase-customer-data.sql"

# インデックスの最適化（データ増加後に推奨）
docker exec sql-tuning-mysql mysql -uroot -ppassword sakila -e "OPTIMIZE TABLE film; OPTIMIZE TABLE actor; OPTIMIZE TABLE customer; ANALYZE TABLE film; ANALYZE TABLE actor; ANALYZE TABLE customer;"
```

#### 生成されるデータの特徴

**Filmテーブル（100,000件）:**
- タイトル: "The Last Warrior Part 1", "Dark Knight Returns" など実在の洋画風
- 公開年: 1980-2024年でランダム化
- 上映時間: 80-180分でランダム化
- レンタル料: $0.99-$6.99でランダム化
- レーティング: G, PG, PG-13, R, NC-17でランダム化

**Actorテーブル（20,000件）:**
- 実在の俳優名60名をベース:
  - Tom Cruise, Brad Pitt, Leonardo DiCaprio
  - Scarlett Johansson, Jennifer Lawrence
  - など
- film_actorリレーションも自動生成（各俳優にランダムで5本の映画を割り当て）

**Customerテーブル（300件）:**
- 一般的な英語圏の姓名（First Name 100種類、Last Name 100種類）
- メールアドレスをランダム生成（gmail.com, yahoo.com等）
- 作成日を過去10年間でランダム化
- Active/Inactiveを95%/5%で分散

#### パフォーマンステストのポイント

大規模データを使用することで、以下のようなリアルな性能差を体験できます：

1. **インデックスの重要性**
   - 1,000件: 数ミリ秒の差
   - 100,000件: 数十倍～数百倍の差

2. **JOINの最適化**
   - N+1問題がより顕著に
   - 適切なJOINの重要性が明確に

3. **サブクエリの最適化**
   - 相関サブクエリの性能劣化が顕著に
   - JOINへの書き換え効果が大きく

4. **ページネーションの必要性**
   - 全件取得のコスト増大
   - LIMIT句の重要性

---

## 🔍 パフォーマンス分析

### 1. アプリケーションログの確認

Spring Bootのコンソールログで、各クエリの実行時間が確認できます：

```
2024-01-15 10:30:45 - searchFilmsByTitleSlow実行時間: 125ms, 取得件数: 10
2024-01-15 10:30:50 - searchFilmsByTitleFast実行時間: 8ms, 取得件数: 10
```

### 2. MySQLでのクエリ実行計画確認

```bash
# MySQLに接続
docker exec -it sql-tuning-mysql mysql -uroot -ppassword sakila

# EXPLAIN で実行計画を確認
mysql> EXPLAIN SELECT * FROM film WHERE title LIKE '%ACADEMY%';
mysql> EXPLAIN SELECT * FROM film WHERE title LIKE 'ACADEMY%';
```

### 3. インデックスの作成とパフォーマンス比較

```sql
-- インデックスなしの状態でクエリを実行
SELECT * FROM film WHERE title LIKE 'ACADEMY%';

-- インデックスを作成
CREATE INDEX idx_title ON film(title);

-- 同じクエリを再実行して速度を比較
SELECT * FROM film WHERE title LIKE 'ACADEMY%';

-- 実行計画を確認
EXPLAIN SELECT * FROM film WHERE title LIKE 'ACADEMY%';
```

---

## 💡 講義での活用例

### デモシナリオ例

#### シナリオ1: インデックスの効果を実演

1. まず、インデックスなしの状態で検索を実行
2. 実行時間を記録（例: 120ms）
3. `CREATE INDEX idx_title ON film(title);` を実行
4. 同じ検索を再実行
5. 実行時間を記録（例: 8ms）
6. **約15倍の性能向上**を確認

#### シナリオ2: EXPLAINの読み方

```sql
EXPLAIN SELECT * FROM film WHERE title LIKE '%ACADEMY%';
```

**結果の解説:**
- `type: ALL` → フルテーブルスキャン（遅い）
- `rows: 1000` → 1000行すべてをスキャン
- `Extra: Using where` → WHERE句でフィルタリング

```sql
EXPLAIN SELECT * FROM film WHERE title LIKE 'ACADEMY%';
```

**インデックス作成後:**
- `type: range` → インデックスレンジスキャン（速い）
- `rows: 少数` → インデックスを使って絞り込み
- `key: idx_title` → 使用されたインデックス

#### シナリオ3: リアルタイムパフォーマンス測定

Webアプリケーションを使って、受講者に実際に操作してもらい、
実行時間の違いを体感してもらいます。

---

## 🛠️ トラブルシューティング

### データベースに接続できない

```bash
# MySQLコンテナの状態を確認
docker ps

# ログを確認
docker-compose logs mysql

# コンテナを再起動
docker-compose restart mysql

# MySQLが起動していることを確認
docker exec -it sql-tuning-mysql mysqladmin ping -ppassword
```

**エラー:** `docker: command not found`
- Docker Desktopがインストールされているか確認してください
- Windowsの場合、Docker Desktopを起動してから操作してください

### Spring Bootが起動しない

**エラー:** `Communications link failure`

**解決方法:** MySQLが完全に起動するまで待ってから、Spring Bootを起動してください。

```bash
# MySQLが起動していることを確認（数秒待つ）
docker exec -it sql-tuning-mysql mysqladmin ping -ppassword
```

**エラー:** `Circular dependencies between beans`

**解決方法:** これは既に解決済みです。`PasswordEncoderConfig.java`が正しく配置されているか確認してください。

**エラー:** `WeakKeyException: The specified key byte array is ... bits`

**解決方法:** これは既に解決済みです。`application.yml`のJWT secret keyが512ビット以上であることを確認してください。

### フロントエンドでAPI接続エラー

**エラー:** `Network Error` または `CORS Error`

**確認事項:**
1. バックエンドが起動しているか（`http://localhost:8080/api/auth/test`）
2. CORS設定が正しいか（`SecurityConfig.java`）
3. ブラウザのコンソールでエラーメッセージを確認

### ログインできない

**問題:** ユーザー名とパスワードが正しいのにログインできない

**確認:**
```sql
-- usersテーブルの確認
SELECT * FROM sakila.users;
```

**解決:** 初期データが投入されていない場合、手動でユーザーを作成：

```sql
-- BCryptハッシュ化されたパスワード "password" でユーザーを作成
INSERT INTO sakila.users (username, password, role) VALUES
('demo', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'USER'),
('admin', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'ADMIN'),
('user', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'USER');
```

**注意:** PowerShellでBCryptハッシュを扱う際は、`$`記号がエスケープされないように注意してください。
文字列は必ずシングルクォート`'`で囲んでください。

### APIテストで401 Unauthorizedエラーが出る

**問題:** `/api/actors`や`/api/films`へのアクセスで401エラーが発生する

**原因:** これらのエンドポイントはJWT認証が必要です。

**解決方法:**
1. まず`/api/auth/login`でログインしてJWTトークンを取得
2. 取得したトークンを`Authorization: Bearer <token>`ヘッダーに設定
3. `test-apis.ps1`スクリプトを使用すると自動的に処理されます

---

## 📚 参考資料

### データベース関連
- [MySQL公式ドキュメント - EXPLAIN](https://dev.mysql.com/doc/refman/8.0/en/explain.html)
- [MySQL公式ドキュメント - インデックスの最適化](https://dev.mysql.com/doc/refman/8.0/en/optimization-indexes.html)
- [Sakila サンプルデータベース](https://dev.mysql.com/doc/sakila/en/)

### MyBatis関連
- [MyBatis 公式ドキュメント](https://mybatis.org/mybatis-3/)
- [MyBatis Spring Boot Starter](https://mybatis.org/spring-boot-starter/mybatis-spring-boot-autoconfigure/)

### Spring Boot関連
- [Spring Boot 公式ドキュメント](https://spring.io/projects/spring-boot)
- [Spring Security 公式ドキュメント](https://spring.io/projects/spring-security)

---

## 🔧 開発者向け情報

### APIエンドポイント

#### 認証
- `POST /api/auth/login` - ログイン
- `GET /api/auth/test` - 接続テスト

#### 映画
- `GET /api/films` - 全映画取得
- `GET /api/films/search/slow?title={title}` - タイトル検索（遅い）
- `GET /api/films/search/fast?title={title}` - タイトル検索（速い）
- `GET /api/films/with-language/slow` - 言語情報付き（遅い）
- `GET /api/films/with-language/fast` - 言語情報付き（速い）
- `GET /api/films/complex/slow?minLength={length}` - 複雑な検索（遅い）
- `GET /api/films/complex/fast?minLength={length}` - 複雑な検索（速い）

#### 俳優
- `GET /api/actors` - 全俳優取得
- `GET /api/actors/search?name={name}` - 名前検索

#### 顧客
- `GET /api/customers/slow` - 全顧客取得（遅い）
- `GET /api/customers/fast` - 全顧客取得（速い）

### データベーススキーマ

主要テーブル：
- `film` - 映画（1000件）
- `actor` - 俳優（200件）
- `film_actor` - 映画と俳優の関連
- `customer` - 顧客（初期3件、拡張可能）
- `language` - 言語
- `users` - ログインユーザー（demo, admin, user）

### プロジェクト構成の補足

```
test-apis.ps1                        # APIテストスクリプト（PowerShell）
backend/src/main/java/com/example/sqltuning/
    config/
        PasswordEncoderConfig.java   # BCryptエンコーダー設定（循環依存回避）
        SecurityConfig.java          # Spring Security + JWT設定
    security/
        JwtAuthenticationFilter.java # JWTトークン検証フィルター
        JwtTokenProvider.java        # JWTトークン生成・検証
```

---

## 📝 ライセンス

このプロジェクトは教育目的で作成されています。

---

## 👥 貢献

バグ報告や機能追加の提案は、GitHubのIssueでお願いします。

---

## 📞 サポート

質問や問題がある場合は、以下の方法でサポートを受けられます：

1. GitHub Issuesで質問を投稿
2. プロジェクトのドキュメントを確認
3. コードのコメントを参照

---

## 🎓 学習のヒント

### 初心者向け
1. まずは各デモを実行して、実行時間の違いを確認
2. Spring BootのログでどのようなSQLが実行されているか確認
3. `database/scripts/03-demo-queries.sql` のコメントを読む

### 中級者向け
1. MyBatisのXMLマッパーを読んで、SQLの違いを理解
2. EXPLAINを使って実行計画を分析
3. インデックスを追加/削除して効果を確認

### 上級者向け
1. より複雑なクエリを追加してパフォーマンスを測定
2. プロファイリングツールを使って詳細分析
3. 大量データでの性能テスト（データを10万件に増やすなど）

---

**Happy Learning! 🚀**
