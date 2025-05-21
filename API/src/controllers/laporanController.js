const pool = require('../config/database');

// Fungsi untuk membuat laporan baru
exports.createReport = async (req, res) => {
  try {
    // Get fields from form data
    const id_user = req.body.id_user;
    const tipe_laporan = req.body.tipe_laporan;
    const lokasi = req.body.lokasi;
    const waktu = req.body.waktu;
    const deskripsi = req.body.deskripsi;
    const status = req.body.status;
    const foto = req.file ? `/uploads/${req.file.filename}` : req.body.foto;

    console.log('Received data:', {
      id_user,
      tipe_laporan,
      lokasi,
      waktu,
      deskripsi,
      status,
      foto
    });

    // Check if id_user exists in the user_app table
    const userCheck = await pool.query('SELECT 1 FROM sigab_app.user_app WHERE id_user = $1', [id_user]);
    if (userCheck.rowCount === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'User dengan ID tersebut tidak ditemukan'
      });
    }

    // Extract coordinates from the lokasi string "(longitude,latitude)"
    let longitude, latitude;
    if (lokasi) {
      // Remove parentheses and split by comma
      const coords = lokasi.replace(/[()]/g, '').split(',');
      longitude = parseFloat(coords[0]);
      latitude = parseFloat(coords[1]);

      if (isNaN(longitude) || isNaN(latitude)) {
        return res.status(400).json({
          status: 'error',
          message: 'Format koordinat tidak valid. Gunakan format "(longitude,latitude)"'
        });
      }
    }

    // Query untuk insert laporan baru ke database
    const result = await pool.query(
      `INSERT INTO sigab_app."laporan" (id_user, tipe_laporan, lokasi, waktu, deskripsi, status, foto, created_at, updated_at) 
      VALUES ($1, $2, point($3, $4), $5, $6, $7, $8, NOW(), NOW()) RETURNING id_laporan`,
      [id_user, tipe_laporan, longitude, latitude, waktu, deskripsi, status, foto]
    );

    res.status(201).json({
      status: 'success',
      message: 'Laporan berhasil dibuat',
      data: { 
        id_laporan: result.rows[0].id_laporan,
        foto_url: foto
      }
    });
  } catch (error) {
    console.error('Error while creating report:', error);
    res.status(500).json({
      status: 'error',
      message: 'Terjadi kesalahan saat membuat laporan: ' + error.message
    });
  }
};

