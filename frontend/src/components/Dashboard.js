import React, { useState } from 'react';
import { filmAPI, actorAPI, customerAPI } from '../services/api';
import './Dashboard.css';

function Dashboard({ onLogout }) {
  const [activeTab, setActiveTab] = useState('films');
  const [films, setFilms] = useState([]);
  const [actors, setActors] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [executionTime, setExecutionTime] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [executedSql, setExecutedSql] = useState('');
  const [executionPlan, setExecutionPlan] = useState([]);

  const username = localStorage.getItem('username');

  const measureTime = async (apiCall) => {
    setLoading(true);
    const startTime = performance.now();
    try {
      const response = await apiCall();
      const endTime = performance.now();
      const time = (endTime - startTime).toFixed(2);
      setExecutionTime(time);
      
      // レスポンスにSQLが含まれている場合は設定
      if (response.data.executedSql) {
        setExecutedSql(response.data.executedSql);
        setExecutionPlan(response.data.executionPlan || []);
        return response.data.films || response.data.actors || response.data.customers || [];
      } else {
        setExecutedSql('');
        setExecutionPlan([]);
        return response.data;
      }
    } catch (error) {
      console.error('API Error:', error);
      alert('データの取得に失敗しました');
      setExecutedSql('');
      setExecutionPlan([]);
      return [];
    } finally {
      setLoading(false);
    }
  };

  // 映画関連のハンドラー
  const handleGetAllFilms = async () => {
    const data = await measureTime(filmAPI.getAllFilms);
    setFilms(data);
  };

  const handleSearchFilmsSlow = async () => {
    if (!searchQuery) {
      alert('検索キーワードを入力してください');
      return;
    }
    const data = await measureTime(() => filmAPI.searchFilmsSlow(searchQuery));
    setFilms(data);
  };

  const handleSearchFilmsFast = async () => {
    if (!searchQuery) {
      alert('検索キーワードを入力してください');
      return;
    }
    const data = await measureTime(() => filmAPI.searchFilmsFast(searchQuery));
    setFilms(data);
  };

  const handleFilmsWithLanguageSlow = async () => {
    const data = await measureTime(filmAPI.getFilmsWithLanguageSlow);
    setFilms(data);
  };

  const handleFilmsWithLanguageFast = async () => {
    const data = await measureTime(filmAPI.getFilmsWithLanguageFast);
    setFilms(data);
  };

  const handleFilmsComplexSlow = async () => {
    const data = await measureTime(() => filmAPI.getFilmsComplexSlow(90));
    setFilms(data);
  };

  const handleFilmsComplexFast = async () => {
    const data = await measureTime(() => filmAPI.getFilmsComplexFast(90));
    setFilms(data);
  };

  // 俳優関連のハンドラー
  const handleGetAllActors = async () => {
    const data = await measureTime(actorAPI.getAllActors);
    setActors(data);
  };

  const handleSearchActors = async () => {
    if (!searchQuery) {
      alert('検索キーワードを入力してください');
      return;
    }
    const data = await measureTime(() => actorAPI.searchActors(searchQuery));
    setActors(data);
  };

  // 顧客関連のハンドラー
  const handleGetCustomersSlow = async () => {
    const data = await measureTime(customerAPI.getAllCustomersSlow);
    setCustomers(data);
  };

  const handleGetCustomersFast = async () => {
    const data = await measureTime(customerAPI.getAllCustomersFast);
    setCustomers(data);
  };

  // インデックス管理ハンドラー
  const handleCreateTitleIndex = async () => {
    setLoading(true);
    try {
      await filmAPI.createTitleIndex();
      alert('インデックスを作成しました');
    } catch (error) {
      console.error('Index creation error:', error);
      alert('インデックスの作成に失敗しました');
    } finally {
      setLoading(false);
    }
  };

  const handleDropTitleIndex = async () => {
    setLoading(true);
    try {
      await filmAPI.dropTitleIndex();
      alert('インデックスを削除しました');
    } catch (error) {
      console.error('Index deletion error:', error);
      alert('インデックスの削除に失敗しました');
    } finally {
      setLoading(false);
    }
  };

  // SQLシンタックスハイライト関数
  const highlightSQL = (sql) => {
    const keywords = ['SELECT', 'FROM', 'WHERE', 'JOIN', 'INNER', 'LEFT', 'RIGHT', 'OUTER', 
                      'ON', 'AND', 'OR', 'ORDER', 'BY', 'GROUP', 'HAVING', 'LIMIT', 
                      'AS', 'DISTINCT', 'COUNT', 'SUM', 'AVG', 'MAX', 'MIN', 'LIKE',
                      'IN', 'EXISTS', 'BETWEEN', 'IS', 'NULL', 'NOT', 'CASE', 'WHEN',
                      'THEN', 'ELSE', 'END', 'INSERT', 'UPDATE', 'DELETE', 'CREATE',
                      'ALTER', 'DROP', 'TABLE', 'INDEX', 'VIEW'];
    
    let highlighted = sql;
    
    // キーワードをハイライト
    keywords.forEach(keyword => {
      const regex = new RegExp(`\\b${keyword}\\b`, 'gi');
      highlighted = highlighted.replace(regex, `<span class="sql-keyword">${keyword}</span>`);
    });
    
    // 文字列リテラルをハイライト
    highlighted = highlighted.replace(/'([^']*)'/g, '<span class="sql-string">\'$1\'</span>');
    
    // 数値をハイライト
    highlighted = highlighted.replace(/\b(\d+)\b/g, '<span class="sql-number">$1</span>');
    
    // コメントをハイライト
    highlighted = highlighted.replace(/(--[^\n]*)/g, '<span class="sql-comment">$1</span>');
    
    return highlighted;
  };

  // Javaコードをシンタックスハイライト
  const highlightJava = (code) => {
    let highlighted = code;
    
    // HTMLエスケープ
    highlighted = highlighted
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
    
    // 保護用のプレースホルダーを使用
    const placeholders = [];
    let placeholderIndex = 0;
    
    // コメントを保護
    highlighted = highlighted.replace(/(\/\/[^\n]*)/g, (match) => {
      const placeholder = `__COMMENT_${placeholderIndex}__`;
      placeholders.push({ placeholder, value: `<span class="java-comment">${match}</span>` });
      placeholderIndex++;
      return placeholder;
    });
    
    // キーワードをハイライト
    const keywords = ['for', 'while', 'do', 'if', 'else', 'switch', 'case', 'break', 
                      'continue', 'return', 'new', 'public', 'private', 'protected', 
                      'static', 'final', 'void', 'interface', 'extends', 
                      'implements', 'try', 'catch', 'finally', 'throw', 'throws', 
                      'import', 'package'];
    
    keywords.forEach(keyword => {
      const regex = new RegExp(`\\b(${keyword})\\b`, 'g');
      highlighted = highlighted.replace(regex, `<span class="java-keyword">$1</span>`);
    });
    
    // 型名をハイライト（List, String, Film等）
    highlighted = highlighted.replace(/\b(List|String|Film|Integer|Boolean|Double|Float|Long|Char)\b/g, '<span class="java-type">$1</span>');
    
    // メソッド名をハイライト（ドットの後ろ）
    highlighted = highlighted.replace(/\.([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/g, '.<span class="java-method">$1</span>(');
    
    // 変数名をハイライト（宣言時と代入時）
    highlighted = highlighted.replace(/&lt;<span class="java-type">([^&]+)<\/span>&gt;\s+([a-z][a-zA-Z0-9_]*)\s+=/g, 
      '&lt;<span class="java-type">$1</span>&gt; <span class="java-variable">$2</span> =');
    highlighted = highlighted.replace(/<span class="java-type">([^<]+)<\/span>\s+([a-z][a-zA-Z0-9_]*)\s+=/g, 
      '<span class="java-type">$1</span> <span class="java-variable">$2</span> =');
    
    // プレースホルダーを戻す
    placeholders.forEach(({ placeholder, value }) => {
      highlighted = highlighted.replace(placeholder, value);
    });
    
    return highlighted;
  };

  // 実行計画をテキスト形式でフォーマット
  const formatExecutionPlan = (plan) => {
    if (!plan || plan.length === 0) return '';
    
    let output = '';
    
    plan.forEach((row, index) => {
      output += `<span class="plan-row-header">Row ${index + 1}:</span>\n`;
      output += '<span class="plan-separator">'.padEnd(60, '-') + '</span>\n';
      
      Object.entries(row).forEach(([key, value]) => {
        const displayValue = value != null ? String(value) : 'NULL';
        const paddedKey = key.padEnd(20);
        
        if (key === 'type') {
          // typeカラムを色分け
          if (value === 'ALL') {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-type-bad">${displayValue}</span>\n`;
          } else if (value === 'index' || value === 'ref' || value === 'eq_ref') {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-type-good">${displayValue}</span>\n`;
          } else {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-value">${displayValue}</span>\n`;
          }
        } else if (key === 'key') {
          // 使用されたインデックスを強調
          if (value) {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-index">${displayValue}</span>\n`;
          } else {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-null">${displayValue}</span>\n`;
          }
        } else if (key === 'rows') {
          // スキャン行数を色分け
          const rowCount = parseInt(value);
          if (rowCount > 10000) {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-rows-bad">${displayValue}</span>\n`;
          } else if (rowCount > 1000) {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-rows-warn">${displayValue}</span>\n`;
          } else {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-rows-good">${displayValue}</span>\n`;
          }
        } else if (key === 'Extra') {
          // Extra情報を色分け
          if (displayValue.includes('Using filesort') || displayValue.includes('Using temporary')) {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-extra-warn">${displayValue}</span>\n`;
          } else if (displayValue.includes('Using index')) {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-extra-good">${displayValue}</span>\n`;
          } else {
            output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-value">${displayValue}</span>\n`;
          }
        } else {
          output += `  <span class="plan-key">${paddedKey}</span>: <span class="plan-value">${displayValue}</span>\n`;
        }
      });
      
      output += '\n';
    });
    
    return output;
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>SQLパフォーマンスチューニングデモ</h1>
        <div className="user-info">
          <span>ようこそ、{username}さん</span>
          <button onClick={onLogout} className="logout-button">ログアウト</button>
        </div>
      </header>

      <div className="dashboard-content">
        <div className="tabs">
          <button
            className={activeTab === 'films' ? 'tab active' : 'tab'}
            onClick={() => setActiveTab('films')}
          >
            映画（Films）
          </button>
          <button
            className={activeTab === 'actors' ? 'tab active' : 'tab'}
            onClick={() => setActiveTab('actors')}
          >
            俳優（Actors）
          </button>
          <button
            className={activeTab === 'customers' ? 'tab active' : 'tab'}
            onClick={() => setActiveTab('customers')}
          >
            顧客（Customers）
          </button>
        </div>

        <div className="controls">
          {activeTab === 'films' && (
            <>
              <h2>映画検索とパフォーマンス比較</h2>
              <div className="search-box">
                <input
                  type="text"
                  placeholder="検索キーワード（例：ACADEMY）"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>
              <div className="button-group">
                <button onClick={handleGetAllFilms} disabled={loading}>
                  全映画取得
                </button>
                <div className="comparison-group">
                  <div className="comparison-header">
                    <h3>デモ1: インデックスの重要性</h3>
                    <div className="index-controls">
                      <button onClick={handleCreateTitleIndex} disabled={loading} className="index-create-button">
                        インデックスを作成
                      </button>
                      <button onClick={handleDropTitleIndex} disabled={loading} className="index-drop-button">
                        インデックスを削除
                      </button>
                    </div>
                  </div>
                  <button onClick={handleSearchFilmsSlow} disabled={loading} className="slow-button">
                    タイトル検索（遅い - LIKE '%keyword%'）
                  </button>
                  <button onClick={handleSearchFilmsFast} disabled={loading} className="fast-button">
                    タイトル検索（速い - インデックス利用）
                  </button>
                </div>
                <div className="comparison-group">
                  <h3>デモ2: JOINの最適化</h3>
                  <div className="demo-explanation">
                    <p><strong>N+1問題とは:</strong></p>
                    <pre className="code-example">
                      <code dangerouslySetInnerHTML={{
                        __html: highlightJava(
`// まずfilmデータを取得
List<Film> films = filmMapper.findFilmsWithLanguageSlow();

// N+1問題: 各filmに対してlanguage名を個別に取得
for (Film film : films) {
    String languageName = filmMapper.findLanguageNameById(film.getLanguageId());
    film.setLanguageName(languageName);
}`)
                      }} />
                    </pre>
                    <p>100件のfilmに対して、1回の初期クエリ + 100回の個別クエリ = <strong>101回のDB問合せ</strong>が発生します。</p>
                  </div>
                  <button onClick={handleFilmsWithLanguageSlow} disabled={loading} className="slow-button">
                    言語情報付き取得（遅い - N+1問題）
                  </button>
                  <button onClick={handleFilmsWithLanguageFast} disabled={loading} className="fast-button">
                    言語情報付き取得（速い - JOIN使用）
                  </button>
                </div>
                <div className="comparison-group">
                  <h3>デモ3: サブクエリの最適化</h3>
                  <button onClick={handleFilmsComplexSlow} disabled={loading} className="slow-button">
                    複雑な検索（遅い - サブクエリ多用）
                  </button>
                  <button onClick={handleFilmsComplexFast} disabled={loading} className="fast-button">
                    複雑な検索（速い - JOIN最適化）
                  </button>
                </div>
              </div>
            </>
          )}

          {activeTab === 'actors' && (
            <>
              <h2>俳優検索</h2>
              <div className="search-box">
                <input
                  type="text"
                  placeholder="俳優名（例：PENELOPE）"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>
              <div className="button-group">
                <button onClick={handleGetAllActors} disabled={loading}>
                  全俳優取得
                </button>
                <button onClick={handleSearchActors} disabled={loading}>
                  名前で検索
                </button>
              </div>
            </>
          )}

          {activeTab === 'customers' && (
            <>
              <h2>顧客データとJOINパフォーマンス</h2>
              <div className="button-group">
                <div className="comparison-group">
                  <h3>デモ4: JOINの最適化</h3>
                  <button onClick={handleGetCustomersSlow} disabled={loading} className="slow-button">
                    顧客取得（遅い - 過度なJOIN）
                  </button>
                  <button onClick={handleGetCustomersFast} disabled={loading} className="fast-button">
                    顧客取得（速い - 必要最小限）
                  </button>
                </div>
              </div>
            </>
          )}

          {executionTime && (
            <div className="execution-time">
              実行時間: <strong>{executionTime}ms</strong>
            </div>
          )}

          {executedSql && (
            <div className="sql-display">
              <h3>実行されたSQL:</h3>
              <pre className="sql-code">
                <code dangerouslySetInnerHTML={{ __html: highlightSQL(executedSql) }} />
              </pre>
            </div>
          )}

          {executionPlan && executionPlan.length > 0 && (
            <div className="execution-plan">
              <h3>実行計画 (EXPLAIN):</h3>
              <pre className="explain-output">
                <code dangerouslySetInnerHTML={{ __html: formatExecutionPlan(executionPlan) }} />
              </pre>
            </div>
          )}
        </div>

        <div className="results">
          {loading && <div className="loading">データを読み込み中...</div>}

          {!loading && activeTab === 'films' && films.length > 0 && (
            <div className="table-container">
              <h3>映画一覧（{films.length}件）</h3>
              <table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>タイトル</th>
                    <th>説明</th>
                    <th>公開年</th>
                    <th>言語</th>
                    <th>レンタル期間</th>
                    <th>料金</th>
                    <th>長さ（分）</th>
                  </tr>
                </thead>
                <tbody>
                  {films.map(film => (
                    <tr key={film.filmId}>
                      <td>{film.filmId}</td>
                      <td>{film.title}</td>
                      <td>{film.description ? film.description.substring(0, 100) + '...' : ''}</td>
                      <td>{film.releaseYear}</td>
                      <td>{film.languageName || '-'}</td>
                      <td>{film.rentalDuration}日</td>
                      <td>¥{film.rentalRate}</td>
                      <td>{film.length}分</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {!loading && activeTab === 'actors' && actors.length > 0 && (
            <div className="table-container">
              <h3>俳優一覧（{actors.length}件）</h3>
              <table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>名</th>
                    <th>姓</th>
                    <th>最終更新</th>
                  </tr>
                </thead>
                <tbody>
                  {actors.map(actor => (
                    <tr key={actor.actorId}>
                      <td>{actor.actorId}</td>
                      <td>{actor.firstName}</td>
                      <td>{actor.lastName}</td>
                      <td>{new Date(actor.lastUpdate).toLocaleString('ja-JP')}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {!loading && activeTab === 'customers' && customers.length > 0 && (
            <div className="table-container">
              <h3>顧客一覧（{customers.length}件）</h3>
              <table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>名</th>
                    <th>姓</th>
                    <th>メール</th>
                    <th>住所</th>
                    <th>都市</th>
                    <th>国</th>
                    <th>ステータス</th>
                  </tr>
                </thead>
                <tbody>
                  {customers.map(customer => (
                    <tr key={customer.customerId}>
                      <td>{customer.customerId}</td>
                      <td>{customer.firstName}</td>
                      <td>{customer.lastName}</td>
                      <td>{customer.email}</td>
                      <td>{customer.address || '-'}</td>
                      <td>{customer.city || '-'}</td>
                      <td>{customer.country || '-'}</td>
                      <td>{customer.active ? 'アクティブ' : '非アクティブ'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default Dashboard;
