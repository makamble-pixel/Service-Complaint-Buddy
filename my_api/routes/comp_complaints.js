const pool = require('../config/db');  // Import the database connection

// Route to fetch completed complaints
app.get('/api/complaints/completed', async (req, res) => {
  try {
    const complaints = await pool.query('SELECT * FROM complaints WHERE status = $1', ['completed']);
    res.json(complaints.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch completed complaints' });
  }
});