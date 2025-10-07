import express from 'express';
const app = express();

// Simple endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', ts: new Date().toISOString() });
});

// Example "risky" pattern for SAST tools to catch if uncommented
// eval("console.log('avoid eval')");

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`App listening on http://127.0.0.1:${port}`);
});
