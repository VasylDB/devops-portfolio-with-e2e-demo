import express from 'express'
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (reg, res) => {
    res.json({ ok: true, app: 'Vasyl cicd-demo-app', ts: new Date().toISOString() });
});

app.listen(port, () => {
    console.log('App listening on port ${port}');
});
