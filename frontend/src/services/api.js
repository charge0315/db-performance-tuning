import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// リクエストインターセプター：トークンを自動的に付与
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// レスポンスインターセプター：401エラーでログアウト
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('username');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// 認証API
export const authAPI = {
  login: (username, password) =>
    api.post('/auth/login', { username, password }),
};

// 映画API
export const filmAPI = {
  // 基本検索
  getAllFilms: () => api.get('/films'),
  getFilmById: (id) => api.get(`/films/${id}`),

  // パフォーマンス比較用API
  searchFilmsSlow: (title) => api.get('/films/search/slow', { params: { title } }),
  searchFilmsFast: (title) => api.get('/films/search/fast', { params: { title } }),

  getFilmsWithLanguageSlow: () => api.get('/films/with-language/slow'),
  getFilmsWithLanguageFast: () => api.get('/films/with-language/fast'),

  getFilmsComplexSlow: (minLength) => api.get('/films/complex/slow', { params: { minLength } }),
  getFilmsComplexFast: (minLength) => api.get('/films/complex/fast', { params: { minLength } }),
};

// 俳優API
export const actorAPI = {
  getAllActors: () => api.get('/actors'),
  searchActors: (name) => api.get('/actors/search', { params: { name } }),
  getActorById: (id) => api.get(`/actors/${id}`),
};

// 顧客API
export const customerAPI = {
  getAllCustomersSlow: () => api.get('/customers/slow'),
  getAllCustomersFast: () => api.get('/customers/fast'),
  getCustomerByEmail: (email) => api.get('/customers/search', { params: { email } }),
};

export default api;
