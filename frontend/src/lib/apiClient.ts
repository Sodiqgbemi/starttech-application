import axios from 'axios';

// Relative /api path so CloudFront can route API traffic to the ALB (no mixed content).
// Locally, set VITE_API_BASE_URL=http://localhost:8080/api in .env
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';

export const apiClient = axios.create({
    baseURL: API_BASE_URL,
    withCredentials: true, // Crucial for httpOnly cookies
});
