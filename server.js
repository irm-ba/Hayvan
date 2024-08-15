const express = require('express');
const nodemailer = require('nodemailer');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Kök rotayı tanımlayın
app.get('/', (req, res) => {
  res.send('Sunucu çalışıyor!');
});

app.post('/send-email', (req, res) => {
  const { name, email, message } = req.body;

  // E-posta gönderen adres olarak `your-email@gmail.com` kullanın.
  // Kullanıcının e-posta adresini 'from' alanında kullanabilirsiniz.
  const transporter = nodemailer.createTransport({
    service: 'Gmail',
    auth: {
      user: 'your-email@gmail.com', // Bu e-posta adresi, e-postayı gönderen adres olacaktır
      pass: 'your-email-password',
    },
  });

  const mailOptions = {
    from: email, // Kullanıcının e-posta adresi burada 'from' olarak ayarlanır
    to: 'felveraa@gmail.com',
    subject: `Contact Form: ${name}`,
    text: message,
  };

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      return res.status(500).send(error.toString());
    }
    res.status(200).send('Email sent: ' + info.response);
  });
});

app.listen(3000, () => {
  console.log('Server started on http://localhost:3000');
});
