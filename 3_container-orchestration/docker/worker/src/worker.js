const Redis = require('ioredis');
const redis =new Redis({ host: process.env.REDIS_HOST || 'redis', port: Number(process.env.REDIS_PORT || 6379) });
(async function run(){ console.log('Worker started'); while(true){ const result = await redis.brpop('jobs',0); const job = result && result[1]; if(job) console.log(`Processed: ${job}`);} })();
