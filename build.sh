#!/bin/bash

echo "==============================================="
echo "🚀 INSTAGRAM MESSAGE BOT - WEB VERSION"
echo "==============================================="

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p public

# Create main web interface
echo "🌐 Creating web interface..."
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instagram Message Bot - Web Version</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #667eea;
            --secondary: #764ba2;
            --success: #28a745;
            --danger: #dc3545;
        }
        
        body {
            font-family: 'Roboto', sans-serif;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            border: none;
            border-radius: 10px;
            padding: 12px 30px;
            font-weight: 500;
        }
        
        .btn-danger {
            background: var(--danger);
            border: none;
            border-radius: 10px;
            padding: 12px 30px;
            font-weight: 500;
        }
        
        .status-indicator {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 8px;
        }
        
        .status-running {
            background: var(--success);
            animation: pulse 1.5s infinite;
        }
        
        .status-stopped {
            background: #6c757d;
        }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
        
        .log-container {
            background: #1e1e1e;
            color: #00ff00;
            font-family: 'Courier New', monospace;
            border-radius: 10px;
            height: 200px;
            overflow-y: auto;
            padding: 15px;
        }
    </style>
</head>
<body>
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="glass-card p-4 p-md-5">
                    <!-- Header -->
                    <div class="text-center mb-5">
                        <h1 class="display-5 fw-bold text-dark mb-3">🤖 Instagram Message Bot</h1>
                        <p class="text-muted lead">Web-based automation tool for Instagram messaging</p>
                    </div>

                    <!-- Status Card -->
                    <div class="alert alert-info d-flex align-items-center mb-4">
                        <div class="status-indicator status-running"></div>
                        <div>
                            <strong>Server Status:</strong> 
                            <span id="serverStatus">Checking...</span>
                            <span id="activeBots" class="badge bg-primary ms-2">0 active</span>
                        </div>
                    </div>

                    <!-- Bot Control Form -->
                    <div class="card border-0 shadow-sm mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">⚙️ Bot Configuration</h5>
                        </div>
                        <div class="card-body">
                            <form id="botForm">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold">👤 Your User ID</label>
                                        <input type="text" class="form-control" id="userId" 
                                               placeholder="Enter unique user ID" required>
                                        <div class="form-text">This identifies your bot session</div>
                                    </div>
                                    
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold">🎭 Hater's Name</label>
                                        <input type="text" class="form-control" id="haterName" 
                                               placeholder="Enter name to show in messages" required>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-semibold">💬 Messages (One per line)</label>
                                    <textarea class="form-control" id="messages" rows="5" 
                                              placeholder="Enter your messages here, one per line" required></textarea>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold">⏱️ Speed (Seconds)</label>
                                        <input type="number" class="form-control" id="speed" 
                                               min="1" value="2" required>
                                        <div class="form-text">Delay between messages in seconds</div>
                                    </div>
                                    
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold">📊 Total Messages</label>
                                        <input type="text" class="form-control" id="totalMessages" 
                                               value="0" readonly>
                                        <div class="form-text">Number of messages to send</div>
                                    </div>
                                </div>

                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <button type="button" class="btn btn-danger me-md-2" id="stopBtn" disabled>
                                        🛑 Stop Bot
                                    </button>
                                    <button type="submit" class="btn btn-primary" id="startBtn">
                                        🚀 Start Bot
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Activity Log -->
                    <div class="card border-0 shadow-sm">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">📋 Activity Log</h5>
                            <button class="btn btn-sm btn-outline-secondary" onclick="clearLog()">
                                Clear
                            </button>
                        </div>
                        <div class="card-body p-0">
                            <div class="log-container" id="logContainer">
                                <div>> System ready. Fill the form and start bot.</div>
                            </div>
                        </div>
                    </div>

                    <!-- Instructions -->
                    <div class="mt-4">
                        <h6>📖 How to Use:</h6>
                        <ol class="small">
                            <li>Enter your unique User ID</li>
                            <li>Set the name that will appear in messages</li>
                            <li>Add your messages (one per line)</li>
                            <li>Set the speed/delay between messages</li>
                            <li>Click "Start Bot" and keep this tab open</li>
                            <li>Go to Instagram and open any chat</li>
                            <li>The bot will automatically send messages</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="app.js"></script>
</body>
</html>
EOF

# Create JavaScript file
cat > public/app.js << 'EOF'
class InstagramBot {
    constructor() {
        this.userId = '';
        this.isRunning = false;
        this.initializeEventListeners();
        this.checkServerStatus();
        setInterval(() => this.checkBotStatus(), 3000);
    }

    initializeEventListeners() {
        // Form submission
        document.getElementById('botForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.startBot();
        });

        // Stop button
        document.getElementById('stopBtn').addEventListener('click', () => {
            this.stopBot();
        });

        // Messages counter
        document.getElementById('messages').addEventListener('input', (e) => {
            const messages = e.target.value.split('\n').filter(msg => msg.trim());
            document.getElementById('totalMessages').value = messages.length;
        });
    }

    async startBot() {
        const userId = document.getElementById('userId').value.trim();
        const haterName = document.getElementById('haterName').value.trim();
        const messages = document.getElementById('messages').value;
        const speed = document.getElementById('speed').value;

        if (!userId || !haterName || !messages || !speed) {
            this.addLog('❌ Please fill all fields', 'error');
            return;
        }

        this.userId = userId;
        this.addLog('🚀 Starting bot...', 'info');

        try {
            const response = await fetch('/api/start-bot', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    userId,
                    haterName,
                    messages,
                    speed
                })
            });

            const data = await response.json();

            if (data.success) {
                this.isRunning = true;
                this.updateUI(true);
                this.addLog('✅ Bot started successfully!', 'success');
                this.addLog(`📊 Total messages: ${data.data.totalMessages}`, 'info');
                this.addLog(`⏱️ Speed: ${data.data.speed} seconds`, 'info');
                this.addLog('💡 Now go to Instagram and open any chat', 'info');
            } else {
                this.addLog(`❌ Error: ${data.error}`, 'error');
            }
        } catch (error) {
            this.addLog(`❌ Network error: ${error.message}`, 'error');
        }
    }

    async stopBot() {
        if (!this.userId) return;

        this.addLog('🛑 Stopping bot...', 'info');

        try {
            const response = await fetch('/api/stop-bot', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    userId: this.userId
                })
            });

            const data = await response.json();

            if (data.success) {
                this.isRunning = false;
                this.updateUI(false);
                this.addLog('✅ Bot stopped successfully!', 'success');
            } else {
                this.addLog(`❌ Error: ${data.error}`, 'error');
            }
        } catch (error) {
            this.addLog(`❌ Network error: ${error.message}`, 'error');
        }
    }

    async checkBotStatus() {
        if (!this.userId) return;

        try {
            const response = await fetch(`/api/bot-status/${this.userId}`);
            const data = await response.json();

            if (data.success && data.status === 'running' && !this.isRunning) {
                this.isRunning = true;
                this.updateUI(true);
            } else if (data.success && data.status === 'stopped' && this.isRunning) {
                this.isRunning = false;
                this.updateUI(false);
            }
        } catch (error) {
            // Silent error for status checks
        }
    }

    async checkServerStatus() {
        try {
            const response = await fetch('/api/active-bots');
            const data = await response.json();
            
            document.getElementById('serverStatus').textContent = 'Online';
            document.getElementById('activeBots').textContent = `${data.count} active`;
        } catch (error) {
            document.getElementById('serverStatus').textContent = 'Offline';
            document.getElementById('activeBots').textContent = '0 active';
        }
    }

    updateUI(isRunning) {
        const startBtn = document.getElementById('startBtn');
        const stopBtn = document.getElementById('stopBtn');

        if (isRunning) {
            startBtn.disabled = true;
            startBtn.innerHTML = '⏳ Running...';
            stopBtn.disabled = false;
        } else {
            startBtn.disabled = false;
            startBtn.innerHTML = '🚀 Start Bot';
            stopBtn.disabled = true;
        }
    }

    addLog(message, type = 'info') {
        const logContainer = document.getElementById('logContainer');
        const timestamp = new Date().toLocaleTimeString();
        const color = type === 'error' ? '#ff4444' : type === 'success' ? '#00ff00' : '#ffffff';
        
        const logEntry = document.createElement('div');
        logEntry.innerHTML = `<span style="color: #888;">[${timestamp}]</span> <span style="color: ${color};">${message}</span>`;
        
        logContainer.appendChild(logEntry);
        logContainer.scrollTop = logContainer.scrollHeight;
    }
}

// Utility function
function clearLog() {
    const logContainer = document.getElementById('logContainer');
    logContainer.innerHTML = '<div>> Log cleared</div>';
}

// Initialize bot when page loads
document.addEventListener('DOMContentLoaded', () => {
    new InstagramBot();
});
EOF

echo "✅ Web version build completed!"
echo "🌐 Now you can deploy on Render and use directly from browser!"
echo "🚀 Users can access via URL and run bots without extension!"
