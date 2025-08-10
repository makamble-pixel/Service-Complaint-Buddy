const express = require('express');
const { Pool } = require('pg');
const router = express.Router();
require('dotenv').config();
const pool = require('../config/db');

// Route to handle adding new customer information
router.post('/', async (req, res) => {
  const { name, complaint, customerType, address, phoneNumber, email } = req.body;

  console.log('Request received:', req.body); // Log incoming request data

  try {
    // Insert the customer information into the database
    const result = await pool.query(
      `INSERT INTO customer_info (name, complaint, customer_type, address, phone_number, user_email)
       VALUES ($1, $2, $3, $4, $5,$6) RETURNING customer_id`,
      [name, complaint, customerType, address, phoneNumber, email]
    );

    const customerId = result.rows[0].customer_id; // Get the generated customer ID

    // Respond with a success message and the customer ID
    res.status(201).send({ message: 'Customer info added successfully!', customerId });
  } catch (error) {
    console.error('Error inserting data:', error); // Log error for debugging
    res.status(500).send({ error: 'Failed to add customer info' });
  }
});

// Add more customer-related routes here as needed

module.exports = router;