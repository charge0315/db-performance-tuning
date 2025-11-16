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

  const username = localStorage.getItem('username');

  const measureTime = async (apiCall) => {
    setLoading(true);
    const startTime = performance.now();
    try {
      const response = await apiCall();
      const endTime = performance.now();
      const time = (endTime - startTime).toFixed(2);
      setExecutionTime(time);
      return response.data;
    } catch (error) {
      console.error('API Error:', error);
      alert('データの取得に失敗しました');
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
                  <h3>デモ1: インデックスの重要性</h3>
                  <button onClick={handleSearchFilmsSlow} disabled={loading} className="slow-button">
                    タイトル検索（遅い - LIKE '%keyword%'）
                  </button>
                  <button onClick={handleSearchFilmsFast} disabled={loading} className="fast-button">
                    タイトル検索（速い - インデックス利用）
                  </button>
                </div>
                <div className="comparison-group">
                  <h3>デモ2: JOINの最適化</h3>
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
