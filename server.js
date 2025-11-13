require('dotenv').config();
const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const db = require('./firebase');
const { default: axios } = require('axios');
const twilio = require('twilio');

const client = twilio(process.env.TWILIO_SID, process.env.TWILIO_AUTH_TOKEN);

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

      const otp = crypto.randomInt(100000, 999999).toString();
      await db.collection('otpgen').doc(phoneNumber).set({
        code: otp,
        expiresAt: Date.now() + 5 * 60 * 1000 // 5 minutes
      });

      await client.messages.create({
        to: phoneNumber,
        body: `Your OTP code is: ${otp}`,
        from: process.env.TWILIO_PHONE_NUMBER,
        to: phoneNumber,
      });

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
app.post('/verify-otp', async (req, res) => {
  const { phoneNumber, code } = req.body;

  try {
    const otpDoc = await db.collection('otp').doc(phoneNumber).get();

    if (!otpDoc.exists) {
      return res.status(404).json({ message: 'OTP not found' });
    }

    const data = otpDoc.data();
    if (Date.now() > data.expiresAt) {
      return res.status(410).json({ message: 'OTP expired' });
    }

    if (data.code !== code) {
      return res.status(401).json({ message: 'Incorrect OTP' });
    }

    await otpDoc.ref.delete(); 

    return res.status(200).json({ message: 'OTP verified' });
  } catch (error) {
    console.error('OTP verification error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
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

