const express = require('express'); const Redis = require('ioredis');
const app = express(); const port = process.env.PORT || 3000; const message = process.env.MESSAGE || 'Hello';
const secretToken = process.env.SECRET_TOKEN || 'not-set';
const redis = new Redis({ host: process.env.REDIS_HOST || 'redis', port: Number(process.env.REDIS_PORT || 6379) });
app.get('/', (_req, res) => res.json({ ok:true, msg: message }));
app.get('/enqueue', async (_req,res)=>{ await redis.lpush('jobs',`job-${Date.now()}`); res.json({ok:true,queued:true});});
app.get('/secret-check', (_req,res)=> res.json({ ok: Boolean(secretToken && secretToken!=='not-set') }));
app.listen(port, ()=> console.log(`API listening on ${port}`));