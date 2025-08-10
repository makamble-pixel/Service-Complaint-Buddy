const express = require('express');
const { Pool } = require('pg');
const router = express.Router();
const pool = require('../config/db');

// const PORT = process.env.PORT || 3000;
require('dotenv').config();

// Route to get complaint data by customer_id
router.get('/complaints/:customer_id', async (req, res) => {
  const customerId = parseInt(req.params.customer_id);

  // Validate customer_id
  if (isNaN(customerId)) {
    return res.status(400).json({ error: 'Invalid customer ID' });
  }

  try {
    const result = await pool.query(
      'SELECT * FROM your_table_name WHERE customer_id = $1', // replace 'your_table_name' with the actual table name
      [customerId]
    );

    if (result.rows.length > 0) {
      res.json(result.rows);
    } else {
      res.status(404).json({ error: 'No complaints found for this customer' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

module.exports = router;