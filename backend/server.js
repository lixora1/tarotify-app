// Tarotify Backend — Node.js / Express
const express = require('express');
const cors = require('cors');
const Anthropic = require('@anthropic-ai/sdk');

const app = express();
app.use(express.json({ limit: '50mb' }));
app.use(cors());

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

// Sağlık kontrolü
app.get('/health', (req, res) => res.json({ status: 'ok', version: '2.0' }));

// Kullanıcı başına rate limit (basit in-memory)
const rateLimitMap = new Map();
const RATE_LIMIT = 30; // dakikada 30 istek
const RATE_WINDOW = 60 * 1000;

function checkRateLimit(ip) {
  const now = Date.now();
  const entry = rateLimitMap.get(ip) || { count: 0, resetAt: now + RATE_WINDOW };
  if (now > entry.resetAt) {
    entry.count = 0;
    entry.resetAt = now + RATE_WINDOW;
  }
  entry.count++;
  rateLimitMap.set(ip, entry);
  return entry.count <= RATE_LIMIT;
}

// Görsel validasyon endpoint'i
app.post('/api/validate', async (req, res) => {
  const ip = req.ip || req.connection.remoteAddress;
  if (!checkRateLimit(ip)) {
    return res.status(429).json({ error: 'Rate limit aşıldı' });
  }

  try {
    const { type, content } = req.body;
    if (!content || !Array.isArray(content)) {
      return res.status(400).json({ error: 'Geçersiz istek' });
    }

    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 100,
      messages: [{ role: 'user', content }],
    });

    const result = response.content
      .filter(b => b.type === 'text')
      .map(b => b.text)
      .join('\n');

    res.json({ result });
  } catch (error) {
    console.error('Validate Error:', error);
    // Validasyon hatası olursa geçerli say
    res.json({ result: '{"valid": true, "message": ""}' });
  }
});

// Ana fal endpoint'i
app.post('/api/fortune', async (req, res) => {
  const ip = req.ip || req.connection.remoteAddress;
  if (!checkRateLimit(ip)) {
    return res.status(429).json({ error: 'Rate limit aşıldı' });
  }

  try {
    const { type, content } = req.body;
    if (!content || !Array.isArray(content)) {
      return res.status(400).json({ error: 'Geçersiz istek' });
    }

    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      messages: [{ role: 'user', content }],
    });

    const result = response.content
      .filter(b => b.type === 'text')
      .map(b => b.text)
      .join('\n');

    res.json({ result });
  } catch (error) {
    console.error('API Error:', error);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Tarotify Backend v2.0 çalışıyor: port ${PORT}`));
