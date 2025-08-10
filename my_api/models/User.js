const pool = require('../config/db');

const createUser = async (name, email, password) => {
    const result = await pool.query(
        'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING *',
        [name, email, password]
    );  ``
    return result.rows[0];
};

const createTc = async (name, email, password) => {
    const result = await pool.query(
        'INSERT INTO technicians (name, email, password) VALUES ($1, $2, $3) RETURNING *',
        [name, email, password]
    );  ``
    return result.rows[0];
};

const findUserByEmail = async (email) => {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    return result.rows[0];
};

const findTcByEmail = async (email) => {
    const result = await pool.query('SELECT * FROM technicians WHERE email = $1', [email]);
    return result.rows[0];
};

// Update user password
const updateUserPassword = async (email, hashedPassword) => {
    await pool.query('UPDATE users SET password = $1 WHERE email = $2', [hashedPassword, email]);
};

const updateTcPassword = async (email, hashedPassword) => {
    await pool.query('UPDATE technicians SET password = $1 WHERE email = $2', [hashedPassword, email]);
};

module.exports = { createUser, findUserByEmail, updateUserPassword, findTcByEmail, updateTcPassword, createTc };