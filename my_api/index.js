const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const authRoutes = require('./routes/authRoutes');
const customerRoutes = require('./routes/customer');
const { login } = require('./controllers/authController');
const authMiddleware = require('./middlewares/authMiddleware');
const complaintRoutes = require('./routes/complaintRoutes');
const bodyParser = require('body-parser');
const pool = require('./config/db');

dotenv.config();

const app = express();
const cron = require('node-cron');

app.use(cors());
app.use(express.json()); // Handles JSON requests
app.use(bodyParser.json()); // Handles JSON requests, can be redundant if you use express.json()

// Define routes
app.use('/', authRoutes); // Auth routes under /api/auth
// app.use('/', complaintRoutes); 

// Route to fetch complaints
app.get('/api/complaints/pending', async (req, res) => {
    try {
      // Query to fetch complaints with a status of 'pending'
      const result = await pool.query(
        `SELECT * FROM complaints WHERE status IN ('registered', 'pending', 'accepted') ORDER BY created_at DESC`);
      // Return the fetched rows as JSON response
      res.json(result.rows);
    } catch (err) {
      // Log the error and return a 500 status with an error message
      console.error(err.message);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
  
  // Route to approve a complaint to an engineer by admin(Example for additional functionality)
  app.post('/api/complaints/approve', async (req, res) => {
    const { complaintId } = req.body;
    try {
      // Update complaint status to 'forwarded' in the database
      await pool.query(
        'UPDATE complaints SET status = $1 WHERE id = $2',
        ['accepted', complaintId]
      );
      // Send success response
      res.json({ message: 'Complaint forwarded successfully' });
    } catch (err) {
      // Handle any errors
      console.error(err.message);
      res.status(500).json({ error: 'Failed to forward complaint' });
    }
  });

// Route to fetch completed complaints
app.get('/api/complaints/completed', async (req, res) => {
    try {
      const complaints = await pool.query('SELECT * FROM complaints WHERE status = $1', ['completed']);
      res.json(complaints.rows);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch completed complaints' });
    }
  });

// Fetch accepted complaints
app.get('/api/complaints/accepted', async (req, res) => {
  try {
      const result = await pool.query("SELECT * FROM complaints WHERE status = 'accepted'");
      res.json(result.rows);
  } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Route to rejecting a complaint
app.post('/api/complaints/rejectComplaint', async (req, res) => {
    const { complaintId } = req.body;
    try {
        // Update complaint status to 'rejected'
        await pool.query('UPDATE complaints SET status = $1 WHERE id = $2', ['rejected', complaintId]);

        // Respond with success
        res.status(200).json({ message: 'Complaint rejected successfully' });
    } catch (error) {
        console.error('Error rejecting complaint:', error);
        res.status(500).json({ message: 'Error rejecting complaint' });
    }
});

// Route to fetch complaint details by ID
app.get('/api/complaints/:id', async (req, res) => {
  const complaintId = parseInt(req.params.id);
  
  if (isNaN(complaintId)) {
    return res.status(400).json({ error: 'Invalid complaint ID' });
  }

  try {
    const result = await pool.query('SELECT * FROM complaints WHERE id = $1', [complaintId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Complaint not found' });
    }

    // Send back the first complaint found (there should only be one)
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching complaint details:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.put('/update-complaint/:id', async (req, res) => {
  const complaintId = req.params.id;
  const { status, assigned_to } = req.body;

  try {
    const result = await pool.query(
      'UPDATE complaints SET status = $1, assigned_to = $2 WHERE id = $3',
      [status, assigned_to, complaintId]
    );

    if (result.rowCount === 0) {
      return res.status(404).send('Complaint not found');
    }
    res.send('Complaint updated successfully');
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
});

// Route to fetch all pending complaints in technician app to take jobs
app.get('/api/complaints/status/pending', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM complaints WHERE status = $1', ['pending']);
    
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching pending complaints:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update complaint status to completed
app.put('/api/update-complaint/:id', async (req, res) => {
  const complaintId = parseInt(req.params.id);

  try {
      // Update the complaint status to 'completed'
      const result = await pool.query(
          `UPDATE complaints SET status = 'completed' WHERE id = $1 RETURNING *`,
          [complaintId]
      );

      if (result.rows.length > 0) {
          // Successfully updated
          res.status(200).json({
              message: 'Complaint status updated to completed successfully',
              complaint: result.rows[0],
          });
      } else {
          // Complaint not found
          res.status(404).json({ message: 'Complaint not found' });
      }
  } catch (error) {
      console.error(error.message);
      res.status(500).json({ message: 'Server error' });
  }
});

// Schedule to run once a day
cron.schedule('0 0 * * *', async () => {
    try {
        // Delete complaints older than a week with status 'rejected'
        await db.query('DELETE FROM complaints WHERE status = $1 AND created_at < NOW() - INTERVAL \'3 days\'', ['rejected']);
        console.log('Old rejected complaints deleted successfully');
    } catch (error) {
        console.error('Error deleting old rejected complaints:', error);
    }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});