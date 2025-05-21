const pool = require('../config/database');

// Fungsi untuk mendapatkan semua informasi banjir
exports.getAllFloodInfo = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM sigab_app."informasi_banjir"');
    res.status(200).json({
      status: 'success',
      data: result.rows
    });
  } catch (error) {
    console.error('Error while fetching flood information:', error);
    res.status(500).json({
      status: 'error',
      message: 'Terjadi kesalahan saat mengambil data informasi banjir'
    });
  }
};
