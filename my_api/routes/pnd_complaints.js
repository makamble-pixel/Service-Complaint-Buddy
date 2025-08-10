/*const pool = require('../config/db');  // Import the database connection

// Route to fetch pending complaints
app.get('/api/complaints/pending', async (req, res) => {
  try {
    const complaints = await pool.query(
      `SELECT * FROM complaints WHERE status IN ('registered', 'pending') ORDER BY created_at DESC`);

    if (complaints.rows.length === 0) {
      console.log("No complaints found.");
    } else {
      console.log("Fetched complaints:", complaints.rows);
    }

    res.json(complaints.rows);
    
  } catch (error) {
    console.error('Error fetching complaints:', error.message);
    res.status(500).json({ error: 'Failed to fetch complaints' });
  }
});
  
// Route to approve a complaint to the engineer
app.post('/api/complaints/approve', async (req, res) => {
  const { complaintId } = req.body;
  try {
    await pool.query('UPDATE complaints SET status = $1 WHERE id = $2', ['approve', complaintId]);
    res.status(200).json({ message: 'Complaint forwarded successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to forward complaint' });
  }
});*/