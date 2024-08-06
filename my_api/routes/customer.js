const express = require('express');
const { Pool } = require('pg');
const router = express.Router();

require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

router.post('/', async (req, res) => {
  const { name, complaint, customerType, address, machineModel, phoneNumber } = req.body;

  console.log('Request received:', req.body); // Log incoming request data

  try {
    await pool.query(
      `INSERT INTO customer_info (name, complaint, customer_type, address, machine_model, phone_number)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [name, complaint, customerType, address, machineModel, phoneNumber]
    );
    res.status(201).send({ message: 'Customer info added successfully!' });
  } catch (error) {
    console.error('Error inserting data:', error); // Log error for debugging
    res.status(500).send({ error: 'Failed to add customer info' });
  }
});

module.exports = router;
