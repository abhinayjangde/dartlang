const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const JWT_SECRET = process.env.JWT_SECRET || 'my-super-secret-jwt-key-thats-at-least-32-chars';
const PORT = process.env.PORT || 4000;

function generateToken(user) {
  const payload = {
    sub: user.id.toString(),
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 7,
    'https://hasura.io/jwt/claims': {
      'x-hasura-allowed-roles': ['user', 'anonymous'],
      'x-hasura-default-role': 'user',
      'x-hasura-user-id': user.id.toString(),
      'x-hasura-role': 'user',
    },
  };
  return jwt.sign(payload, JWT_SECRET);
}

app.post('/signup', async (req, res) => {
  const { username, email, password, displayName } = req.body;
  if (!username || !email || !password) {
    return res.status(400).json({ error: 'Username, email and password required' });
  }
  try {
    const existing = await pool.query(
      'SELECT id FROM users WHERE username = $1 OR email = $2',
      [username, email]
    );
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Username or email already exists' });
    }
    const passwordHash = await bcrypt.hash(password, 10);
    const result = await pool.query(
      `INSERT INTO users (id, username, email, password_hash, display_name)
       VALUES ($1, $2, $3, $4, $5) RETURNING id, username, email, display_name, avatar_url, created_at`,
      [uuidv4(), username, email, passwordHash, displayName || username]
    );
    const user = result.rows[0];
    const token = generateToken(user);
    res.status(201).json({ token, user });
  } catch (err) {
    console.error('Signup error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }
  try {
    const result = await pool.query(
      'SELECT id, username, email, display_name, avatar_url, password_hash, created_at FROM users WHERE email = $1',
      [email]
    );
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const token = generateToken(user);
    delete user.password_hash;
    res.json({ token, user });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/users', async (req, res) => {
  const auth = req.headers.authorization;
  if (!auth) return res.status(401).json({ error: 'No token' });
  try {
    const decoded = jwt.verify(auth.replace('Bearer ', ''), JWT_SECRET);
    const result = await pool.query(
      'SELECT id, username, email, display_name, avatar_url, is_online, last_seen FROM users WHERE id != $1 ORDER BY display_name',
      [decoded.sub]
    );
    res.json({ users: result.rows });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

app.get('/users/:id', async (req, res) => {
  const auth = req.headers.authorization;
  if (!auth) return res.status(401).json({ error: 'No token' });
  try {
    jwt.verify(auth.replace('Bearer ', ''), JWT_SECRET);
    const result = await pool.query(
      'SELECT id, username, email, display_name, avatar_url, is_online, last_seen FROM users WHERE id = $1',
      [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'User not found' });
    res.json({ user: result.rows[0] });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

app.listen(PORT, () => {
  console.log(`Auth server running on port ${PORT}`);
});
