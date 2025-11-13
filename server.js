require('dotenv').config();
const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const db = require('./firebase');
const { default: axios } = require('axios');
const twilio = require('twilio');

//const client = twilio(process.env.TWILIO_SID, process.env.TWILIO_AUTH_TOKEN);

const app = express();
app.use(cors());
app.use(express.json());

app.post('/phonelogin', async (req, res) => {
  const { phoneNumber, pin } = req.body;

  try {
    const snapshot = await db.collection('pensioners')
      .where('phoneNumber', '==', phoneNumber)
      .where('status', '==', 'Active')
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'User not found' });
    }

    const doc = snapshot.docs[0];
    const data = doc.data();

    if (data.status === 'Blocked') {
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
      if (attempts >= 5) updates.status = 'Blocked';

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

//

app.post('/phoneloginSes', async (req, res) => {
  const { phoneNumber, pin } = req.body;

  try {
    const snapshot = await db.collection('pensioners')
      .where('phoneNumber', '==', phoneNumber)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'Mokholi ea joalo ha a fumanehe.' });
    }

    const doc = snapshot.docs[0];
    const data = doc.data();

    if (data.status === 'Blocked') {
      return res.status(403).json({ message: 'Mokholi o kibuoe.' });
    }

    if (data.pin === pin) {
      await doc.ref.update({ loginAttempts: 0 });

      return res.status(200).json({
        message: 'U se u kene akhaontong ea hau.',
        id: doc.id,
        name: data.name,
        phoneNumber: data.phoneNumber,
        activity: data.activity
      });
    } else {
      const attempts = (data.loginAttempts || 0) + 1;
      const updates = { loginAttempts: attempts };
      if (attempts >= 5) updates.status = 'Blocked';

      await doc.ref.update(updates);

      return res.status(401).json({
        message: 'U fositse linomoro tsa hau tsa lekunutu.',
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

