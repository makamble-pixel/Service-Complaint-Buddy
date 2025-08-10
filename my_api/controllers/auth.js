const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const { createUser, findUserByEmail, updateUserPassword, findTcByEmail, updateTcPassword, createTc } = require('../models/User');
const pool = require('../config/db');
const { tc_changePassword, tc_login } = require('./authController');

let otpStorage = {}; // Temporary storage for OTPs
let otpStore = {};

const transporter = nodemailer.createTransport({
    service: 'Gmail',
    auth: {
        user: process.env.EMAIL_USER, // Your Gmail address
        pass: process.env.EMAIL_PASS, // Your Gmail app password
    },
});

const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

const register = async (req, res) => {
    const { name, email, password } = req.body;
    try {
        const existingUser = await findUserByEmail(email);
        if (existingUser) {
            return res.status(400).json({ message: 'User already exists' });
        }
        const existingTc = await findTcByEmail(email);
        if (existingTc) {
            return res.status(400).json({ message: 'Technician already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const otp = generateOTP();

        // Send OTP via email
        await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Your OTP for Registration',
            text: `Your OTP is ${otp}`,
        });

        // Store OTP and user details temporarily
        otpStorage[email] = { otp, name, hashedPassword };

        res.status(200).json({ message: 'OTP sent to your email' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
};

const tc_register = async (req, res) => {
  const { name, email, password } = req.body;
  try {
      const existingTc = await findTcByEmail(email);
      if (existingTc) {
          return res.status(400).json({ message: 'Technician already exists' });
      }
      const existingUser = await findUserByEmail(email);
      if (existingUser) {
          return res.status(400).json({ message: 'User already exists in user app' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const otp = generateOTP();

      // Send OTP via email
      await transporter.sendMail({
          from: process.env.EMAIL_USER,
          to: email,
          subject: 'Your OTP for Registration',
          text: `Your OTP is ${otp}`,
      });

      // Store OTP and user details temporarily
      otpStorage[email] = { otp, name, hashedPassword };

      res.status(200).json({ message: 'OTP sent to your email' });
  } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Server error' });
  }
};

// Send OTP for forgot password
const sendForgotPasswordOTP = async (req, res) => {
  const { email } = req.body;
  try {
    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const otp = generateOTP();
    otpStore[email] = otp;

    // Send OTP to email
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Your OTP for Password Reset',
      text: `Your OTP is ${otp}`,
    });

    res.status(200).json({ message: 'OTP sent to your email' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const tc_sendForgotPasswordOTP = async (req, res) => {
  const { email } = req.body;
  try {
    const user = await findTcByEmail(email);
    if (!user) {
      return res.status(404).json({ message: 'Technician not found' });
    }

    const otp = generateOTP();
    otpStore[email] = otp;

    // Send OTP to email
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Your OTP for Password Reset',
      text: `Your OTP is ${otp}`,
    });

    res.status(200).json({ message: 'OTP sent to your email' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Verify OTP for forgot password
const verifyForgotPasswordOTP = async (req, res) => {
  const { email, otp } = req.body;
  try {
    const storedOtp = otpStore[email];
    if (!storedOtp || storedOtp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    // OTP verified, allow password reset
    delete otpStore[email]; // Remove OTP after verification
    res.status(200).json({ message: 'OTP verified' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Verify OTP for registering new user
const verifyOTP = async (req, res) => {
  const { email, otp } = req.body;
  try {
      const storedData = otpStorage[email];
      if (!storedData || storedData.otp !== otp) {
          return res.status(400).json({ message: 'Invalid OTP' });
      }

      // OTP verified, save user to the database
      const newUser = await createUser(storedData.name, email, storedData.hashedPassword);
      delete otpStorage[email]; // Remove OTP after successful verification

      res.status(201).json(newUser);
  } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Server error' });
  }
};

const tc_verifyOTP = async (req, res) => {
  const { email, otp } = req.body;
  try {
      const storedData = otpStorage[email];
      if (!storedData || storedData.otp !== otp) {
          return res.status(400).json({ message: 'Invalid OTP' });
      }

      // OTP verified, save user to the database
      const newUser = await createTc(storedData.name, email, storedData.hashedPassword);
      delete otpStorage[email]; // Remove OTP after successful verification

      res.status(201).json(newUser);
  } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Server error' });
  }
};

// Reset Password
const resetPassword = async (req, res) => {
  const { email, newPassword, confirmPassword } = req.body;
  try {
    if (newPassword !== confirmPassword) {
      return res.status(400).json({ message: 'Passwords do not match' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await updateUserPassword(email, hashedPassword);

    res.status(200).json({ message: 'Password reset successful' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const tc_resetPassword = async (req, res) => {
  const { email, newPassword, confirmPassword } = req.body;
  try {
    if (newPassword !== confirmPassword) {
      return res.status(400).json({ message: 'Passwords do not match' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await updateUserPassword(email, hashedPassword);

    res.status(200).json({ message: 'Password reset successful' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { register, verifyOTP, sendForgotPasswordOTP, verifyForgotPasswordOTP, resetPassword, tc_register, tc_resetPassword, tc_sendForgotPasswordOTP, tc_verifyOTP };