const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
// Hapus userController dari sini karena sudah ditangani di userRoutes.js
// const userController = require('../controllers/userController'); 
const laporanController = require('../controllers/laporanController');
const tipsMitigasiController = require('../controllers/tipsMitigasiController');
const informasiBanjirController = require('../controllers/informasiBanjirController');
const tempatEvakuasiController = require('../controllers/tempatEvakuasiController');
const riwayatBanjirController = require('../controllers/riwayatBanjirController');
const notifikasiController = require('../controllers/notifikasiController');
const informasiCuacaController = require('../controllers/informasiCuacaController');
const { verifyToken } = require('../middlewares/authMiddleware');

// Impor userRoutes baru
const userRoutes = require('./userRoutes');

// Konfigurasi multer untuk upload file
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, '../../public/uploads/'));
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  fileFilter: function (req, file, cb) {
    if (!file.originalname.match(/\.(jpg|jpeg|png)$/)) {
      return cb(new Error('Hanya file gambar yang diperbolehkan!'), false);
    }
    cb(null, true);
  },
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  }
});

// Gunakan userRoutes untuk endpoint yang berkaitan dengan pengguna
// Biasanya diawali dengan /auth atau /users
router.use('/users', userRoutes); 

// Hapus endpoint register, login, dan logout yang lama dari sini
// router.post('/register', userController.register);
// router.post('/login', userController.login);
// router.post('/logout', userController.logoutUser);


// Endpoint untuk mengambil semua data user (jika masih diperlukan, bisa dipindah ke userRoutes atau adminRoutes)
// router.get('/users', userController.getAllUsers);

// Endpoint untuk mengambil semua laporan
// router.get('/laporan', laporanController.getAllReports);
router.post('/laporan', verifyToken, upload.single('foto'), laporanController.createReport);

// Endpoint untuk mengambil semua tips mitigasi
router.get('/tips-mitigasi', tipsMitigasiController.getAllMitigationTips);

// Endpoint untuk mengambil semua informasi banjir
router.get('/informasi-banjir', informasiBanjirController.getAllFloodInfo);

// Endpoint untuk mengambil semua tempat evakuasi
router.get('/tempat-evakuasi', tempatEvakuasiController.getAllEvacuationPlaces);

// Endpoint untuk mengambil semua riwayat banjir
router.get('/riwayat-banjir', riwayatBanjirController.getAllFloodHistory);

// Endpoint untuk mengambil semua notifikasi
router.get('/notifikasi', notifikasiController.getAllNotifications);

router.get('/cuaca',informasiCuacaController.getWeather);

// Logout route sudah dipindahkan ke userRoutes
// router.post('/logout', userController.logoutUser);

module.exports = router;
