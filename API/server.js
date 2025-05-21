const express = require('express');
const cors = require('cors');
const app = express();
require('dotenv').config();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Import routes
const appRoutes = require('./src/routes/appRoutes');
const userRoutes = require('./src/routes/userRoutes');

// Gunakan routes
app.use('/api/app', appRoutes);
app.use('/api/users', userRoutes);

// Endpoint root
app.get('/', (req, res) => {
  res.json({
    message: 'Selamat datang di API SIGAB (Sistem Informasi dan Kesiapsiagaan Banjir)'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    status: 'error',
    message: err.message || 'Terjadi kesalahan pada server'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Endpoint tidak ditemukan'
  });
});

// Jalankan server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server SIGAB berjalan di port ${PORT}`);
});

module.exports = app;