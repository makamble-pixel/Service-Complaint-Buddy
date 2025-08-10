const express = require('express');
const { login, changePassword, tc_login, tc_changePassword } = require('../controllers/authController');
const { register, verifyOTP, sendForgotPasswordOTP, verifyForgotPasswordOTP, resetPassword, tc_register, tc_verifyOTP } = require('../controllers/auth');
const { getProfile, getTechnicianProfile } = require('../controllers/profileController');
const authMiddleware = require('../middlewares/authMiddleware');
const { createComplaint, getComplaintsByEmail, getComplaintsByEmailandStatus, getComplaintsByStatus,getComplaintsByAssignedEmailAndStatus, getPendingComplaints, verifyComplaint ,} = require('../controllers/complaintController');
const db = require('../config/db');
const router = express.Router();

//login, register and change password routes for technician app
router.post('/technician/login', tc_login);
router.post('/technician/register', tc_register);
router.post('/technician/verify-OTP', tc_verifyOTP);
router.post('/technician/changePassword', authMiddleware, tc_changePassword);

//login, register and change password routes for user app
router.post('/login', login);
router.post('/register', register);
router.post('/verify-OTP', verifyOTP);
router.post('/changePassword', authMiddleware, changePassword);

// Route to get user profile
router.get('/getProfile', authMiddleware, getProfile);

//Route to get technician profile
router.get('/getProfile', authMiddleware, getTechnicianProfile);

// forgot password routes
router.post('/send-otp', sendForgotPasswordOTP);
router.post('/verifyForgotPasswordOTP', verifyForgotPasswordOTP);
router.post('/reset-password', resetPassword);

// complaint routes
router.post('/submitComplaint', createComplaint);
router.get('/api/complaints', getComplaintsByEmail);
router.get('/api/complaints/status', getComplaintsByEmailandStatus);
router.get('/api/complaints/admin/status', getComplaintsByStatus);
// Route to fetch complaint by ID
router.get('/complaint/:id', async (req, res) => {
    const complaintId = req.params.id;
    try {
      const result = await db.query('SELECT * FROM complaints WHERE id = $1', [complaintId]);
      if (result.rows.length > 0) {
        res.status(200).json(result.rows[0]);
      } else {
        res.status(404).json({ message: 'Complaint not found' });
      }
    } catch (error) {
      console.error('Error fetching complaint:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

/*//admin app routes
router.post('/verifyComplaint', verifyComplaint)
router.get('/pendingComplaints', getPendingComplaints)*/

//For tech complaints
router.get('/api/tech/complaints/status', getComplaintsByAssignedEmailAndStatus);

module.exports = router;