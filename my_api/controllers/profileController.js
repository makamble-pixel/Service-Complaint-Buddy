const db = require('../config/db'); // Import your database connection

// Function to get profile info
exports.getProfile = async (req, res) => {
  try {
    const userId = req.user.id; // Assuming `user.id` is added to the req object in authMiddleware

    const profile = await db.query(
      `SELECT name, email, phone, address, city, state, zip FROM users WHERE id = $1`,
      [userId]
    );

    if (profile.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.status(200).json({
      name: profile.rows[0].name,
      email: profile.rows[0].email,
      phone: profile.rows[0].phone,
      address: profile.rows[0].address,
      city: profile.rows[0].city,
      state: profile.rows[0].state,
      zip: profile.rows[0].zip,
    });
  } catch (error) {
    return res.status(500).json({ message: 'Server error' });
  }
};

// Function to get technician profile info
exports.getTechnicianProfile = async (req, res) => {
  try {
    const technicianId = req.user.id; // Assuming `user.id` is added to the req object in authMiddleware

    const profile = await db.query(
      `SELECT name, email, phone, address, city, state, zip FROM technicians WHERE id = $1`,
      [technicianId]
    );

    if (profile.rows.length === 0) {
      return res.status(404).json({ message: 'Technician not found' });
    }

    return res.status(200).json({
      name: profile.rows[0].name,
      email: profile.rows[0].email,
      phone: profile.rows[0].phone,
      address: profile.rows[0].address,
      city: profile.rows[0].city,
      state: profile.rows[0].state,
      zip: profile.rows[0].zip,
    });
  } catch (error) {
    return res.status(500).json({ message: 'Server error' });
  }
};