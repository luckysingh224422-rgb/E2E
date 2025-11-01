const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/extension', express.static(path.join(__dirname, 'extension')));

// Main Route
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// API Status
app.get('/api/status', (req, res) => {
    res.json({
        status: '🟢 Online',
        service: 'Instagram Message Bot',
        version: '2.0.0',
        platform: 'Render',
        deployed: true
    });
});

// Download Extension
app.get('/download-extension', (req, res) => {
    const extensionPath = path.join(__dirname, 'extension.zip');
    
    res.json({
        message: 'Extension ready for download',
        download_url: '/download/extension',
        instructions: 'Download, extract, and load in Chrome'
    });
});

// Serve extension files
app.get('/extension/:file', (req, res) => {
    const file = req.params.file;
    const filePath = path.join(__dirname, 'extension', file);
    
    if (fs.existsSync(filePath)) {
        res.sendFile(filePath);
    } else {
        res.status(404).json({ error: 'File not found' });
    }
});

// Health check
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Instagram Message Bot Server Started!`);
    console.log(`📍 Port: ${PORT}`);
    console.log(`🌐 URL: http://0.0.0.0:${PORT}`);
    console.log(`⏰ Time: ${new Date().toLocaleString()}`);
    console.log(`📧 Service: Instagram Auto Welcome Bot`);
});
