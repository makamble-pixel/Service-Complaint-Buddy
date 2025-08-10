const jwt = require('jsonwebtoken');

function authMiddleware(req, res, next) {
  // Extract the token from the Authorization header
  const token = req.headers['authorization']?.split(' ')[1];

  // If no token is provided, return 401 Unauthorized
  if (!token) {
    return res.status(401).json({ message: 'No token provided, authorization failed' });
  }

  // Verify the token
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      console.log('Token verification failed:', err);
      return res.status(403).json({ message: 'Token verification failed, access denied' });
    }

    // Attach the user object to the request
    req.user = user;
    console.log('User authenticated:', req.user);
    next(); // Move on to the next middleware or route handler
  });
}

/*const adminMiddleware = (req, res, next) => {
  const token = req.header('x-auth-token');
  // Verify token and extract user role
  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  if (decoded.role !== 'admin') {
    return res.status(403).send('Access denied.');
  }
  next();
};*/

module.exports = authMiddleware; //adminMiddleware;