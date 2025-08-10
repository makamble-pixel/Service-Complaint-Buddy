const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');
const User = require('../models/User');
const nodemailer = require('nodemailer');

// Registration endpoint
const register = async (req, res) => {
    const { name, email, password } = req.body;

    // Input validation
    if (!name || !email || !password) {
        return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    try {
        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert new user into the database
        const result = await pool.query(
            'INSERT INTO users (name, email, password) VALUES ($1, $2, $3)',
            [name, email, hashedPassword]
        );

        // Respond with the newly created user
        res.status(201).json({
            id: result.rows[0].id,
            name: result.rows[0].name,
            email: result.rows[0].email
        });
    } catch (err) {
        // Handle specific errors
        if (err.code === '23505') { // Unique constraint violation
            return res.status(409).json({ error: 'Email already registered' });
        }
        console.error('Registration error:', err);
        res.status(500).send('Server error');
    }
};

const tc_register = async (req, res) => {
    const { name, email, password } = req.body;

    // Input validation
    if (!name || !email || !password) {
        return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    try {
        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert new user into the database
        const result = await pool.query(
            'INSERT INTO technicians (name, email, password) VALUES ($1, $2, $3)',
            [name, email, hashedPassword]
        );

        // Respond with the newly created user
        res.status(201).json({
            id: result.rows[0].id,
            name: result.rows[0].name,
            email: result.rows[0].email
        });
    } catch (err) {
        // Handle specific errors
        if (err.code === '23505') { // Unique constraint violation
            return res.status(409).json({ error: 'Email already registered' });
        }
        console.error('Registration error:', err);
        res.status(500).send('Server error');
    }
};

// Login endpoint
const login = async (req, res) => {
    const { email, password } = req.body;

    // Input validation
    if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
    }

    try {
        // Fetch the user from the database
        const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        const user = result.rows[0];

        if (!user) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Compare the provided password with the stored hashed password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Generate a JWT token containing the email
        const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });

        res.json({ token, email: user.email }); // Return token and email
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).send('Server error');
    }
};

const tc_login = async (req, res) => {
    const { email, password } = req.body;

    // Input validation
    if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
    }

    try {
        // Fetch the user from the database
        const result = await pool.query('SELECT * FROM technicians WHERE email = $1', [email]);
        const user = result.rows[0];

        if (!user) {
            return res.status(400).json({ error: 'Email address not found' });
        }

        // Compare the provided password with the stored hashed password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'Incorrect password' });
        }

        // Generate a JWT token containing the email
        const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });

        res.json({ token, email: user.email }); // Return token and email
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).send('Server error');
    }
};

const changePassword = async (req, res) => {
  try {
    if (!req.user || !req.user.email) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const { currentPassword, newPassword, confirmPassword } = req.body;
    const email = req.user.email; // Use the email from the authenticated user's session
    
    if (!currentPassword || !newPassword || !confirmPassword) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    if (newPassword !== confirmPassword) {
        return res.status(400).json({ error: 'New password and confirmation do not match' });
    }

        // Fetch the user from the database using email
        const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        const user = result.rows[0];

        

        // Check if the current password matches
        const isMatch = await bcrypt.compare(currentPassword, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: 'Current password is incorrect' });
        }

        // Hash the new password and update it in the database
        const hashedNewPassword = await bcrypt.hash(newPassword, 10);
        await pool.query('UPDATE users SET password = $1 WHERE email = $2', [hashedNewPassword, email]);

        // Send a confirmation email
        const transporter = nodemailer.createTransport({
            service: 'Gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS,
            },
        });
        
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Password Changed',
            text: `Your password for $email has been successfully changed. If you did not initiate this change, please contact support immediately.`,
          };

        await transporter.sendMail(mailOptions);

        res.status(200).json({ message: 'Password changed successfully' });
      } catch (err) {
        console.error('Change password error:', err);
        res.status(500).send('Server error');
      }
};

const tc_changePassword = async (req, res) => {
    try {
      if (!req.user || !req.user.email) {
        return res.status(401).json({ message: 'Unauthorized' });
      }
  
      const { currentPassword, newPassword, confirmPassword } = req.body;
      const email = req.user.email; // Use the email from the authenticated user's session
      
      if (!currentPassword || !newPassword || !confirmPassword) {
        return res.status(400).json({ error: 'All fields are required' });
      }
  
      if (newPassword !== confirmPassword) {
          return res.status(400).json({ error: 'New password and confirmation do not match' });
      }
  
          // Fetch the user from the database using email
          const result = await pool.query('SELECT * FROM technicians WHERE email = $1', [email]);
          const user = result.rows[0];
  
          
  
          // Check if the current password matches
          const isMatch = await bcrypt.compare(currentPassword, user.password);
          if (!isMatch) {
              return res.status(400).json({ error: 'Current password is incorrect' });
          }
  
          // Hash the new password and update it in the database
          const hashedNewPassword = await bcrypt.hash(newPassword, 10);
          await pool.query('UPDATE technicians SET password = $1 WHERE email = $2', [hashedNewPassword, email]);
  
          // Send a confirmation email
          const transporter = nodemailer.createTransport({
              service: 'Gmail',
              auth: {
                  user: process.env.EMAIL_USER,
                  pass: process.env.EMAIL_PASS,
              },
          });
          
          const mailOptions = {
              from: process.env.EMAIL_USER,
              to: email,
              subject: 'Password Changed',
              text: `Your password for $email has been successfully changed. If you did not initiate this change, please contact support immediately.`,
            };
  
          await transporter.sendMail(mailOptions);
  
          res.status(200).json({ message: 'Password changed successfully' });
        } catch (err) {
          console.error('Change password error:', err);
          res.status(500).send('Server error');
        }
  };

module.exports = { register, login, changePassword, tc_register, tc_login, tc_changePassword };