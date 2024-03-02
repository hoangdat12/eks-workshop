const express = require('express');
const bodyParser = require('body-parser');

const app = express();

app.use(bodyParser.json());

app.get('/user', async (req, res) => {
  const message = {
    msg: 'User Server',
    users: [
      {
        email: 'tthoangdat18@gmail.com',
        firstName: 'Tran',
        lastName: 'Dat',
      },
    ],
  };

  return res.status(200).json(message);
});

app.listen(5001);
