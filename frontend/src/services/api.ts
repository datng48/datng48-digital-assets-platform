import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:3000/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const auth = {
  register: (data: any) => api.post('/register', { user: data }),
  login: (data: any) => api.post('/login', data),
};

export const assets = {
  list: () => api.get('/assets'),
  get: (id: number) => api.get(`/assets/${id}`),
  create: (data: any) => api.post('/assets', data),
  update: (id: number, data: any) => api.put(`/assets/${id}`, data),
  delete: (id: number) => api.delete(`/assets/${id}`),
  bulkImport: (data: { assets: string }) => api.post('/assets/bulk_import', data),
};

export const purchases = {
  list: () => api.get('/purchases'),
  create: (data: any) => api.post('/purchases', data),
  purchased: () => api.get('/purchased_assets'),
};

export const earnings = {
  getCreatorEarnings: () => api.get('/creator_earnings'),
};

export default api; 