const pool = require('../config/database');

// Fungsi untuk membuat laporan baru
exports.createReport = async (req, res) => {
  try {
    const id_user = req.body.id_user;
    const tipe_laporan = req.body.tipe_laporan;
    const lokasi = req.body.lokasi; // Nama lokasi seperti "Masjid An-Nur"
    const titik_lokasi = req.body.titik_lokasi; // Bentuk string: "(107.61,-6.982)"
    const waktu = req.body.waktu;
    const deskripsi = req.body.deskripsi;
    const status = req.body.status;
    const foto = req.file ? `/uploads/${req.file.filename}` : req.body.foto;

    console.log('Received data:', {
      id_user,
      tipe_laporan,
      lokasi,
      titik_lokasi,
      waktu,
      deskripsi,
      status,
      foto
    });

    const requiredFields = {
      id_user,
      tipe_laporan,
      waktu,
      deskripsi,
      lokasi,
      titik_lokasi,
      foto
    };

    for (const [key, value] of Object.entries(requiredFields)) {
      if (!value || value.toString().trim() === '') {
        return res.status(400).json({
          status: 'error',
          message: `Field '${key}' wajib diisi`
        });
      }
    }

    // Validasi user
    const userCheck = await pool.query('SELECT 1 FROM sigab_app.user_app WHERE id_user = $1', [id_user]);
    if (userCheck.rowCount === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'User dengan ID tersebut tidak ditemukan'
      });
    }

    // Validasi titik format (opsional)
    if (titik_lokasi) {
      const match = titik_lokasi.match(/^\((-?\d+(\.\d+)?),\s*(-?\d+(\.\d+)?)\)$/);
      if (!match) {
        return res.status(400).json({
          status: 'error',
          message: 'Format koordinat tidak valid. Gunakan format "(longitude,latitude)"'
        });
      }
    }

    // Insert laporan
    const result = await pool.query(
      `INSERT INTO sigab_app.laporan 
      (id_user, tipe_laporan, waktu, deskripsi, status, foto, created_at, updated_at, lokasi, titik_lokasi) 
      VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW(), $7, $8)
      RETURNING id_laporan`,
      [id_user, tipe_laporan, waktu, deskripsi, status, foto, lokasi, titik_lokasi]
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
