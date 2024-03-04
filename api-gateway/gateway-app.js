const express = require('express');
const {
  createProxyMiddleware,
  responseInterceptor,
} = require('http-proxy-middleware');

const app = express();

app.use(express.json());

const gatewayMiddleware = ({ target }) => {
  return createProxyMiddleware({
    target,
    changeOrigin: true,
    secure: false,
    onProxyReq: (proxyReq, req, res) => {
      if (req.body) {
        const bodyData = JSON.stringify(req.body);
        proxyReq.setHeader('Content-Type', 'application/json');
        proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
        proxyReq.write(bodyData);
      }
      proxyReq.end();
    },
    on: {
      proxyRes: responseInterceptor(
        async (responseBuffer, proxyRes, req, res) => {
          // log complete response
          const response = responseBuffer.toString('utf8');
          console.log(response);
          return responseBuffer;
        }
      ),
    },
  });
};

app.use(
  '/user',
  gatewayMiddleware({
    target: `http://${process.env.USER_APP}:5001`,
  })
);

app.use(
  '/auth',
  gatewayMiddleware({ target: `http://${process.env.AUTH_APP}:5002` })
);

app.listen(80);
