const pool = require('../config/database');

// Fungsi untuk mendapatkan semua notifikasi
exports.getAllNotifications = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM sigab_app."notifikasi" ORDER BY created_at DESC');
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

// Fungsi untuk mengecek jumlah laporan banjir valid dalam satu hari
exports.checkFloodReports = async (req, res) => {
  try {
    // Menggunakan CURRENT_DATE dari database untuk menghindari isu zona waktu server
    // const today = new Date();
    // today.setHours(0, 0, 0, 0);
    // const todayStr = today.toISOString().slice(0, 10); // 'YYYY-MM-DD'

    // console.log('DEBUG: todayStr used in query:', todayStr);

    const result = await pool.query(
      `SELECT COUNT(*) as total
       FROM sigab_app.laporan
       WHERE tipe_laporan = 'Banjir'
       AND status = 'Valid'
       AND DATE(waktu) = CURRENT_DATE` // Menggunakan CURRENT_DATE dari DB
    );

    console.log('DEBUG: Query result from DB:', result.rows);

    const totalValidReports = parseInt(result.rows[0].total);

    res.status(200).json({
      status: 'success',
      data: {
        total_valid_reports: totalValidReports,
        should_notify: totalValidReports >= 3
      }
    });
  } catch (error) {
    console.error('Error while checking flood reports:', error);
    res.status(500).json({
      status: 'error',
      message: 'Terjadi kesalahan saat mengecek laporan banjir'
    });
  }
};

// Fungsi untuk mendapatkan riwayat notifikasi
exports.getNotificationHistory = async (req, res) => {
  try {
    // Mengambil tanggal instalasi (timestamp penuh) dari query parameter
    const { installed_at } = req.query;
    
    if (!installed_at) {
      return res.status(400).json({
        status: 'error',
        message: 'Timestamp instalasi aplikasi diperlukan'
      });
    }

    // Query untuk mendapatkan notifikasi yang dibuat setelah timestamp instalasi
    const result = await pool.query(
      `SELECT *
       FROM sigab_app.notifikasi
       WHERE created_at >= $1::timestamp with time zone
       ORDER BY created_at DESC
       LIMIT 50`,
      [installed_at]
    );

    res.status(200).json({
      status: 'success',
      data: result.rows
    });
  } catch (error) {
    console.error('Error while fetching notification history:', error);
    res.status(500).json({
      status: 'error',
      message: 'Terjadi kesalahan saat mengambil riwayat notifikasi'
    });
  }
};
