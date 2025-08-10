const pool = require('../config/db');

const createComplaint = async (req, res) => {
  const { name, email, phone, appliance, brand, underWarranty, description, address, city, state, zip } = req.body;
  try {
    const newComplaint = await pool.query(
      `INSERT INTO complaints (name, email, phone, appliance, brand, underwarranty, description, address, city, state, zip, status) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, 'registered' ) RETURNING *`,
      [name, email, phone, appliance, brand, underWarranty, description, address, city, state, zip]
    );
    res.status(200).send({ message: 'Complaint submitted successfully' });
  } catch (err) {
    console.error('Error saving complaint:', err);
    res.status(500).send({ error: 'Failed to submit complaint' });
  }
};

// Route to fetch complaints by user email
const getComplaintsByEmail = async (req, res) => {
  const { email } = req.query;
  try {
    const userComplaints = await pool.query(
      'SELECT * FROM complaints WHERE email = $1',
      [email]
    );
    res.json(userComplaints.rows);
  } catch (err) {
    console.error('Error fetching complaints:', err.message);
    res.status(500).send('Server Error');
  }
};

// Route to fetch complaints by user email and status
const getComplaintsByEmailandStatus = async (req, res) => {
  const { email } = req.query;
  try {
    const userComplaints = await pool.query(
      'SELECT * FROM complaints WHERE email = $1 AND status IN ($2, $3)',
      [email, 'completed', 'rejected'] // Ensure 'completed' and 'rejected' are included
    );
    res.json(userComplaints.rows);
  } catch (err) {
    console.error('Error fetching complaints:', err.message);
    res.status(500).send('Server Error');
  }
};

// Route to fetch complaints with completed or rejected status
const getComplaintsByStatus = async (req, res) => {
  try {
    const status = ['completed', 'rejected'];
    const userComplaints = await pool.query(
      'SELECT * FROM complaints WHERE status = ANY($1::text[])',
      [status]
    );
    res.json(userComplaints.rows);
  } catch (err) {
    console.error('Error fetching complaints:', err.message);
    res.status(500).send('Server Error');
  }
};


/*const getPendingComplaints = async (req, res) => {
  try {
      const result = await pool.query(
          `SELECT * FROM complaints WHERE status IN ('registered', 'pending') ORDER BY created_at DESC`
      );
      res.status(200).json(result.rows);
  } catch (error) {
      console.error('Error fetching pending complaints:', error);
      res.status(500).json({ error: 'Error fetching pending complaints' });
  }
};

const verifyComplaint = async (req, res) => {
  const { id } = req.params;
  try {
      const result = await pool.query(
          `UPDATE complaints SET status = 'pending' WHERE id = $1 RETURNING *`,
          [id]
      );
      if (result.rows.length === 0) {
          return res.status(404).json({ error: 'Complaint not found' });
      }
      res.status(200).json(result.rows[0]);
  } catch (error) {
      console.error('Error verifying complaint:', error);
      res.status(500).json({ error: 'Error verifying complaint' });
  }
};*/

const getComplaintsByAssignedEmailAndStatus = async (req, res) => {
  const { email } = req.query; // This should be the technician's email
  try {
    const userComplaints = await pool.query(
      'SELECT * FROM complaints WHERE assigned_to LIKE $1 AND status IN ($2)',
      [`%${email}%`, 'completed'] // Match the email in assigned_to column
    );

    if (userComplaints.rows.length === 0) {
      console.log(`No complaints found for assigned_to email: ${email}`);
    }

    res.json(userComplaints.rows);
  } catch (err) {
    console.error('Error fetching complaints:', err.message);
    res.status(500).send('Server Error');
  }
}; 

 module.exports = { createComplaint, getComplaintsByEmail, getComplaintsByEmailandStatus, getComplaintsByAssignedEmailAndStatus, getComplaintsByStatus /*getPendingComplaints, verifyComplaint*/ };