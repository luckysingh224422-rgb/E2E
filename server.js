const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Store active bots (in-memory)
const activeBots = new Map();

// Routes
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/control', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'control.html'));
});

// API to start bot
app.post('/api/start-bot', (req, res) => {
    const { userId, messages, speed, haterName } = req.body;
    
    if (!userId || !messages || !speed || !haterName) {
        return res.status(400).json({ 
            success: false, 
            error: 'All fields are required' 
        });
    }

    // Store bot configuration
    activeBots.set(userId, {
        messages: messages.split('\n').filter(msg => msg.trim()),
        speed: parseInt(speed) * 1000,
        haterName: haterName,
        status: 'running',
        startTime: new Date()
    });

    console.log(`🤖 Bot started for user: ${userId}`);
    
    res.json({
        success: true,
        message: 'Bot started successfully!',
        data: {
            userId,
            totalMessages: messages.split('\n').filter(msg => msg.trim()).length,
            speed: speed,
            haterName: haterName
        }
    });
});

// API to stop bot
app.post('/api/stop-bot', (req, res) => {
    const { userId } = req.body;
    
    if (activeBots.has(userId)) {
        activeBots.delete(userId);
        console.log(`🛑 Bot stopped for user: ${userId}`);
        res.json({ success: true, message: 'Bot stopped successfully!' });
    } else {
        res.json({ success: false, error: 'No active bot found for this user' });
    }
});

// API to check bot status
app.get('/api/bot-status/:userId', (req, res) => {
    const { userId } = req.params;
    
    if (activeBots.has(userId)) {
        const bot = activeBots.get(userId);
        res.json({
            success: true,
            status: 'running',
            data: bot
        });
    } else {
        res.json({
            success: true,
            status: 'stopped'
        });
    }
});

// Get active bots count
app.get('/api/active-bots', (req, res) => {
    res.json({
        success: true,
        count: activeBots.size,
        bots: Array.from(activeBots.entries()).map(([userId, bot]) => ({
            userId,
            ...bot
        }))
    });
});

// Health check
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        activeBots: activeBots.size
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Instagram Message Bot Server Started!`);
    console.log(`📍 Port: ${PORT}`);
    console.log(`🌐 URL: http://0.0.0.0:${PORT}`);
    console.log(`📧 Service: Web-based Instagram Bot`);
});
