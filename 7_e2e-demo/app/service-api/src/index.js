const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/healthz', (req, res) => res.json({ status: 'ok' }));
app.get('/', (req, res) => res.json({
  service: 'service-api',
  env: process.env.ENV || 'local',
  version: process.env.VERSION || 'dev'
}));

app.listen(port, () => console.log(`service-api listening on port ${port}`));
