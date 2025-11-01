#!/bin/bash

echo "==============================================="
echo "🚀 FACEBOOK MESSENGER BOT - TOKEN VERSION"
echo "==============================================="

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p public

# Install node-fetch
echo "📦 Installing dependencies..."

# Create main web interface
echo "🌐 Creating Facebook Messenger Bot interface..."
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Facebook Messenger Bot - Token Version</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --facebook-blue: #1877f2;
            --facebook-green: #42b72a;
            --facebook-dark: #1c1e21;
        }
        
        body {
            font-family: 'Roboto', sans-serif;
            background: linear-gradient(135deg, var(--facebook-blue) 0%, var(--facebook-dark) 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .btn-facebook {
            background: var(--facebook-blue);
            border: none;
            border-radius: 8px;
            padding: 12px 30px;
            font-weight: 500;
            color: white;
        }
        
        .btn-success {
            background: var(--facebook-green);
            border: none;
            border-radius: 8px;
            padding: 12px 30px;
            font-weight: 500;
        }
        
        .btn-danger {
            background: #dc3545;
            border: none;
            border-radius: 8px;
            padding: 12px 30px;
            font-weight: 500;
        }
        
        .token-info {
            background: #e7f3ff;
            border-left: 4px solid var(--facebook-blue);
            border-radius: 8px;
        }
        
        .log-container {
            background: #1e1e1e;
            color: #00ff00;
            font-family: 'Courier New', monospace;
            border-radius: 10px;
            height: 250px;
            overflow-y: auto;
            padding: 15px;
        }
        
        .step-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin: 10px 0;
            border-left: 4px solid var(--facebook-blue);
        }
    </style>
</head>
<body>
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="glass-card p-4 p-md-5">
                    <!-- Header -->
                    <div class="text-center mb-5">
                        <i class="fab fa-facebook-messenger fa-3x text-primary mb-3"></i>
                        <h1 class="display-5 fw-bold text-dark mb-2">Facebook Messenger Bot</h1>
                        <p class="text-muted lead">Automated messaging using Facebook Graph API</p>
                    </div>

                    <!-- Status Card -->
                    <div class="alert alert-info d-flex align-items-center mb-4">
                        <i class="fas fa-circle me-2 text-success"></i>
                        <div class="flex-grow-1">
                            <strong>Server Status:</strong> 
                            <span id="serverStatus">Checking...</span>
                            <span id="activeBots" class="badge bg-primary ms-2">0 active bots</span>
                        </div>
                    </div>

                    <!-- Instructions -->
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <div class="step-card">
                                <h6><i class="fas fa-key me-2"></i>Step 1: Get Access Token</h6>
                                <p class="small mb-0">You need a Facebook Page Access Token with permissions:</p>
                                <ul class="small mb-0">
                                    <li>pages_messaging</li>
                                    <li>pages_manage_metadata</li>
                                </ul>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="step-card">
                                <h6><i class="fas fa-user me-2"></i>Step 2: Get Recipient ID</h6>
                                <p class="small mb-0">Find the Facebook User ID or Page ID where you want to send messages</p>
                            </div>
                        </div>
                    </div>

                    <!-- Bot Control Form -->
                    <div class="card border-0 shadow-sm mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0"><i class="fas fa-cogs me-2"></i>Bot Configuration</h5>
                        </div>
                        <div class="card-body">
                            <form id="botForm">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold">
                                            <i class="fas fa-user me-1"></i>Your User ID
                                        </label>
                                        <input type="text" class="form-control" id="userId" 
                                               placeholder="Enter unique session ID" required>
                                        <div class="form-text">Used to identify your bot session</div>
                                    </div>
                                    
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold">
                                            <i class="fas fa-signature me-1"></i>Sender Name
                                        </label>
                                        <input type="text" class="form-control" id="senderName" 
                                               placeholder="Name to show in messages" required>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold">
                                            <i class="fas fa-key me-1"></i>Facebook Access Token
                                        </label>
                                        <input type="password" class="form-control" id="accessToken" 
                                               placeholder="Paste Facebook Page Access Token" required>
                                        <div class="form-text">Page access token with messaging permissions</div>
                                    </div>
                                    
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-semibold">
                                            <i class="fas fa-user-circle me-1"></i>Recipient Facebook ID
                                        </label>
                                        <input type="text" class="form-control" id="recipientId" 
                                               placeholder="Facebook User ID or Page ID" required>
                                        <div class="form-text">The ID where messages will be sent</div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-semibold">
                                        <i class="fas fa-comments me-1"></i>Messages (One per line)
                                    </label>
                                    <textarea class="form-control" id="messages" rows="4" 
                                              placeholder="Enter your messages here, one per line" required></textarea>
                                    <div class="form-text">Each line will be sent as a separate message</div>
                                </div>

                                <div class="row">
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-semibold">
                                            <i class="fas fa-tachometer-alt me-1"></i>Speed (Seconds)
                                        </label>
                                        <input type="number" class="form-control" id="speed" 
                                               min="2" value="3" required>
                                        <div class="form-text">Delay between messages</div>
                                    </div>
                                    
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-semibold">
                                            <i class="fas fa-list-ol me-1"></i>Total Messages
                                        </label>
                                        <input type="text" class="form-control" id="totalMessages" 
                                               value="0" readonly>
                                    </div>
                                    
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-semibold">
                                            <i class="fas fa-stopwatch me-1"></i>Estimated Time
                                        </label>
                                        <input type="text" class="form-control" id="estimatedTime" 
                                               value="0s" readonly>
                                    </div>
                                </div>

                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <button type="button" class="btn btn-danger me-md-2" id="stopBtn" disabled>
                                        <i class="fas fa-stop me-1"></i>Stop Bot
                                    </button>
                                    <button type="submit" class="btn btn-success" id="startBtn">
                                        <i class="fas fa-play me-1"></i>Start Messenger Bot
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Token Help -->
                    <div class="alert alert-warning mb-4">
                        <h6><i class="fas fa-info-circle me-2"></i>How to Get Facebook Access Token:</h6>
                        <ol class="small mb-0">
                            <li>Go to <a href="https://developers.facebook.com/" target="_blank">Facebook Developers</a></li>
                            <li>Create an app and add "Facebook Login" product</li>
                            <li>Add "pages_messaging" permission</li>
                            <li>Get Page Access Token from Graph API Explorer</li>
                        </ol>
                    </div>

                    <!-- Activity Log -->
                    <div class="card border-0 shadow-sm">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fas fa-list-alt me-2"></i>Activity Log</h5>
                            <div>
                                <span class="badge bg-success me-2" id="sentCount">Sent: 0</span>
                                <button class="btn btn-sm btn-outline-secondary" onclick="clearLog()">
                                    <i class="fas fa-trash me-1"></i>Clear
                                </button>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <div class="log-container" id="logContainer">
                                <div>> System ready. Configure your bot and start sending messages.</div>
                            </div>
                        </div>
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
class FacebookMessengerBot {
    constructor() {
        this.userId = '';
        this.isRunning = false;
        this.sentCount = 0;
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

        // Messages counter and time estimator
        document.getElementById('messages').addEventListener('input', (e) => {
            this.updateMessageStats();
        });

        document.getElementById('speed').addEventListener('input', (e) => {
            this.updateMessageStats();
        });
    }

    updateMessageStats() {
        const messages = document.getElementById('messages').value.split('\n').filter(msg => msg.trim());
        const speed = parseInt(document.getElementById('speed').value) || 3;
        const totalMessages = messages.length;
        
        document.getElementById('totalMessages').value = totalMessages;
        
        // Calculate estimated time
        const totalSeconds = totalMessages * speed;
        const estimatedTime = totalSeconds < 60 ? 
            `${totalSeconds} seconds` : 
            `${Math.floor(totalSeconds / 60)} minutes ${totalSeconds % 60} seconds`;
        
        document.getElementById('estimatedTime').value = estimatedTime;
    }

    async startBot() {
        const userId = document.getElementById('userId').value.trim();
        const accessToken = document.getElementById('accessToken').value.trim();
        const recipientId = document.getElementById('recipientId').value.trim();
        const senderName = document.getElementById('senderName').value.trim();
        const messages = document.getElementById('messages').value;
        const speed = document.getElementById('speed').value;

        // Validation
        if (!userId || !accessToken || !recipientId || !senderName || !messages || !speed) {
            this.addLog('❌ Please fill all fields', 'error');
            return;
        }

        if (speed < 2) {
            this.addLog('❌ Speed should be at least 2 seconds to avoid rate limits', 'error');
            return;
        }

        this.userId = userId;
        this.addLog('🚀 Starting Facebook Messenger Bot...', 'info');

        try {
            const response = await fetch('/api/start-fb-bot', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    userId,
                    accessToken,
                    recipientId,
                    senderName,
                    messages,
                    speed
                })
            });

            const data = await response.json();

            if (data.success) {
                this.isRunning = true;
                this.updateUI(true);
                this.addLog('✅ Facebook Messenger Bot started successfully!', 'success');
                this.addLog(`📄 Page: ${data.data.pageName}`, 'info');
                this.addLog(`👤 Recipient: ${data.data.recipientId}`, 'info');
                this.addLog(`📊 Total messages: ${data.data.totalMessages}`, 'info');
                this.addLog(`⏱️ Speed: ${data.data.speed} seconds`, 'info');
                this.addLog('💡 Messages will be sent automatically...', 'info');
            } else {
                this.addLog(`❌ Error: ${data.error}`, 'error');
            }
        } catch (error) {
            this.addLog(`❌ Network error: ${error.message}`, 'error');
        }
    }

    async stopBot() {
        if (!this.userId) return;

        this.addLog('🛑 Stopping Facebook Messenger Bot...', 'info');

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

            if (data.success && data.status === 'running') {
                if (!this.isRunning) {
                    this.isRunning = true;
                    this.updateUI(true);
                }
                // Update sent count
                if (data.data && data.data.totalSent > this.sentCount) {
                    this.sentCount = data.data.totalSent;
                    document.getElementById('sentCount').textContent = `Sent: ${this.sentCount}`;
                }
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
            document.getElementById('activeBots').textContent = `${data.count} active bots`;
        } catch (error) {
            document.getElementById('serverStatus').textContent = 'Offline';
            document.getElementById('activeBots').textContent = '0 active bots';
        }
    }

    updateUI(isRunning) {
        const startBtn = document.getElementById('startBtn');
        const stopBtn = document.getElementById('stopBtn');

        if (isRunning) {
            startBtn.disabled = true;
            startBtn.innerHTML = '<i class="fas fa-sync-alt fa-spin me-1"></i>Running...';
            stopBtn.disabled = false;
        } else {
            startBtn.disabled = false;
            startBtn.innerHTML = '<i class="fas fa-play me-1"></i>Start Messenger Bot';
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
    new FacebookMessengerBot();
});
EOF

echo "✅ Facebook Messenger Bot build completed!"
echo "🔑 Features included:"
echo "   - Facebook Access Token authentication"
echo "   - Graph API integration"
echo "   - Page and user messaging"
echo "   - Real-time logging"
echo "   - Multiple bot sessions"
echo "🚀 Ready for deployment on Render!"
