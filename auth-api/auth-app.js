const express = require('express');
const bodyParser = require('body-parser');

const app = express();

app.use(bodyParser.json());

app.get('/auth/generate-token', async (req, res) => {
  const message = {
    msg: 'Auth Server',
    accessToken: 'Example access token',
  };

  return res.status(200).json(message);
});

app.listen(5002);
