const express = require('express');
const cors = require('cors');
const db = require('./firebase');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/phonelogin', async (req, res) => {
  const { phoneNumber, pin } = req.body;

  try {
    const snapshot = await db.collection('pensioners')
      .where('phoneNumber', '==', phoneNumber)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'User not found' });
    }

    const doc = snapshot.docs[0];
    const data = doc.data();

    if (data.activity === 'Blocked') {
      return res.status(403).json({ message: 'Account is blocked' });
    }

    if (data.pin === pin) {
      await doc.ref.update({ loginAttempts: 0 });

      return res.status(200).json({
        message: 'Login successful',
        id: doc.id,
        name: data.name,
        phoneNumber: data.phoneNumber,
        activity: data.activity
      });
    } else {
      const attempts = (data.loginAttempts || 0) + 1;
      const updates = { loginAttempts: attempts };
      if (attempts >= 5) updates.activity = 'Blocked';

      await doc.ref.update(updates);

      return res.status(401).json({
        message: 'Incorrect PIN',
        attempts,
        blocked: attempts >= 5
      });
    }
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});