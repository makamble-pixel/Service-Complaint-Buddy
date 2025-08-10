const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const pool = require('../config/db');
//const { Pool } = require('pg');  // Import Pool from pg

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Define routes
app.get('/complaints/:email', async (req, res) => {
  const email = req.params.email;
  try {
    const result = await pool.query('SELECT * FROM complaints WHERE email = $1', [email]);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch complaints' });
  }
});

// Start server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});