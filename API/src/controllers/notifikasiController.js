const pool = require('../config/database');

// Fungsi untuk mendapatkan semua notifikasi
exports.getAllNotifications = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM sigab_app."notifikasi"');
    res.status(200).json({
      status: 'success',
      data: result.rows
    });
  } catch (error) {
    console.error('Error while fetching notifications:', error);
    res.status(500).json({
      status: 'error',
      message: 'Terjadi kesalahan saat mengambil data notifikasi'
    });
  }
};
