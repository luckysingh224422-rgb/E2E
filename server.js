const express = require('express');
const path = require('path');
const fetch = require('node-fetch');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Store active bots
const activeBots = new Map();

// Facebook Graph API base URL
const FB_API_BASE = 'https://graph.facebook.com/v18.0';

// Routes
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// API to start Facebook Messenger bot
app.post('/api/start-fb-bot', async (req, res) => {
    const { 
        userId, 
        accessToken, 
        recipientId, 
        messages, 
        speed, 
        senderName 
    } = req.body;
    
    if (!userId || !accessToken || !recipientId || !messages || !speed || !senderName) {
        return res.status(400).json({ 
            success: false, 
            error: 'All fields are required' 
        });
    }

    try {
        // Verify token and get page info
        const pageInfo = await verifyFacebookToken(accessToken);
        if (!pageInfo.success) {
            return res.status(400).json({
                success: false,
                error: pageInfo.error
            });
        }

        const messageList = messages.split('\n').filter(msg => msg.trim());
        
        // Store bot configuration
        activeBots.set(userId, {
            accessToken,
            recipientId,
            messages: messageList,
            speed: parseInt(speed) * 1000,
            senderName,
            pageId: pageInfo.page_id,
            pageName: pageInfo.page_name,
            status: 'running',
            currentIndex: 0,
            startTime: new Date(),
            totalSent: 0
        });

        console.log(`🤖 Facebook Bot started for user: ${userId}, Page: ${pageInfo.page_name}`);

        // Start message sending
        sendFacebookMessage(userId);

        res.json({
            success: true,
            message: 'Facebook Messenger Bot started successfully!',
            data: {
                userId,
                pageName: pageInfo.page_name,
                recipientId,
                totalMessages: messageList.length,
                speed: speed,
                senderName: senderName
            }
        });

    } catch (error) {
        console.error('Error starting bot:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to start bot: ' + error.message
        });
    }
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

// Verify Facebook token and get page info
async function verifyFacebookToken(accessToken) {
    try {
        const response = await fetch(
            `${FB_API_BASE}/me?fields=id,name,accounts{id,name,access_token}&access_token=${accessToken}`
        );
        
        const data = await response.json();
        
        if (data.error) {
            return {
                success: false,
                error: `Token Error: ${data.error.message}`
            };
        }

        // Get first page (you can modify this to select specific page)
        if (data.accounts && data.accounts.data.length > 0) {
            const page = data.accounts.data[0];
            return {
                success: true,
                page_id: page.id,
                page_name: page.name,
                page_access_token: page.access_token
            };
        } else {
            return {
                success: false,
                error: 'No Facebook pages found for this token'
            };
        }
    } catch (error) {
        return {
            success: false,
            error: 'Failed to verify token: ' + error.message
        };
    }
}

// Send Facebook message function
async function sendFacebookMessage(userId) {
    if (!activeBots.has(userId)) return;

    const bot = activeBots.get(userId);
    
    if (bot.currentIndex >= bot.messages.length) {
        bot.currentIndex = 0; // Restart from beginning
    }

    const message = `${bot.senderName}: ${bot.messages[bot.currentIndex]}`;
    
    try {
        // Send message via Facebook Graph API
        const response = await fetch(
            `${FB_API_BASE}/${bot.recipientId}/messages?access_token=${bot.accessToken}`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    messaging_type: "MESSAGE_TAG",
                    tag: "CONFIRMED_EVENT_UPDATE",
                    message: {
                        text: message
                    }
                })
            }
        );

        const result = await response.json();

        if (result.error) {
            console.error(`Facebook API Error for user ${userId}:`, result.error);
            
            // Stop bot on critical errors
            if (result.error.code === 190 || result.error.code === 104) { // Invalid token errors
                activeBots.delete(userId);
                return;
            }
        } else {
            console.log(`✅ Message sent to ${bot.recipientId}: ${message}`);
            bot.totalSent++;
        }

        // Move to next message
        bot.currentIndex++;
        
        // Continue sending if bot is still active
        if (activeBots.has(userId)) {
            setTimeout(() => sendFacebookMessage(userId), bot.speed);
        }

    } catch (error) {
        console.error(`Error sending message for user ${userId}:`, error);
        
        // Continue with next message even if one fails
        bot.currentIndex++;
        if (activeBots.has(userId)) {
            setTimeout(() => sendFacebookMessage(userId), bot.speed);
        }
    }
}

// Get active bots count
app.get('/api/active-bots', (req, res) => {
    res.json({
        success: true,
        count: activeBots.size,
        bots: Array.from(activeBots.entries()).map(([userId, bot]) => ({
            userId,
            pageName: bot.pageName,
            recipientId: bot.recipientId,
            totalSent: bot.totalSent,
            status: bot.status
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
    console.log(`🚀 Facebook Messenger Bot Server Started!`);
    console.log(`📍 Port: ${PORT}`);
    console.log(`🌐 URL: http://0.0.0.0:${PORT}`);
    console.log(`📧 Service: Facebook Messenger Auto Bot`);
});
