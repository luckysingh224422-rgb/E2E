#!/bin/bash

echo "==============================================="
echo "🚀 INSTAGRAM MESSAGE BOT - RENDER DEPLOYMENT"
echo "==============================================="

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p public
mkdir -p extension

# Create extension files
echo "🔧 Creating extension files..."

# manifest.json
cat > extension/manifest.json << 'EOF'
{
  "manifest_version": 3,
  "name": "Instagram Auto Welcome Bot",
  "version": "1.0",
  "description": "Send messages from uploaded TXT file with style.",
  "permissions": ["scripting", "activeTab"],
  "action": {
    "default_popup": "popup.html"
  },
  "background": {
    "service_worker": "background.js"
  },
  "host_permissions": ["<all_urls>"]
}
EOF

# background.js
cat > extension/background.js << 'EOF'
// Background script placeholder
console.log("Instagram Auto Welcome Bot background script loaded");
EOF

# content_script.js
cat > extension/content_script.js << 'EOF'
let isSending = false;
let timeoutId = null;

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.stop) {
        stopSending();
        sendResponse({status: "stopped"});
        return;
    }
    
    if (request.messages && request.speed && request.haterName) {
        stopSending(); // Stop any existing sending
        sendMessages(request.messages, request.speed, request.haterName);
        sendResponse({status: "started"});
    }
    return true;
});

function sendMessages(messages, speed, haterName) {
    if (isSending) return;
    isSending = true;
    
    let index = 0;
    let retryCount = 0;
    const maxRetries = 5;
    
    function sendNextMessage() {
        if (!isSending) return;
        
        if (!messages || !messages.length) {
            console.error("No messages provided");
            stopSending();
            return;
        }
        
        const message = `${haterName}: ${messages[index]}`;
        const inputBox = document.querySelector('[contenteditable="true"]');
        
        if (!inputBox) {
            console.log("Input box not found, retrying...");
            retryCount++;
            if (retryCount < maxRetries) {
                timeoutId = setTimeout(sendNextMessage, 1000);
            } else {
                console.error("Max retries reached. Input box not found.");
                stopSending();
            }
            return;
        }
        
        retryCount = 0;
        
        try {
            inputBox.focus();
            document.execCommand("selectAll", false, null);
            document.execCommand("delete", false, null);
            document.execCommand("insertText", false, message);
            
            const event = new KeyboardEvent('keydown', {
                key: 'Enter', code: 'Enter', keyCode: 13, which: 13, bubbles: true
            });
            inputBox.dispatchEvent(event);
            
            console.log(`✅ Message ${index + 1} sent: ${message}`);
            
            index = (index + 1) % messages.length;
            timeoutId = setTimeout(sendNextMessage, speed);
            
        } catch (error) {
            console.error("Error sending message:", error);
            retryCount++;
            if (retryCount < maxRetries) {
                timeoutId = setTimeout(sendNextMessage, 1000);
            } else {
                stopSending();
            }
        }
    }
    
    sendNextMessage();
}

function stopSending() {
    isSending = false;
    if (timeoutId) {
        clearTimeout(timeoutId);
        timeoutId = null;
    }
    console.log("🛑 Message sending stopped");
}
EOF

# popup.html
cat > extension/popup.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Send Messages</title>
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body {
      background: linear-gradient(135deg, #f3f3f3, #e3e3e3);
      padding: 20px;
      font-family: 'Arial', sans-serif;
      width: 350px;
    }
    .form-control, .btn, .stop-btn {
      margin-top: 10px;
    }
    .stop-btn {
      background-color: red;
      color: white;
    }
    .upload-label {
      margin-top: 10px;
      color: green;
    }
  </style>
</head>
<body>
  <h4 class="text-center">📤 Instagram Message Bot</h4>
  <label for="HatersName"><span class="material-icons">person</span> Hater's Name:</label>
  <input type="text" id="HatersName" class="form-control" placeholder="Enter Hater's Name">

  <label class="upload-label" for="fileInput"><span class="material-icons">upload_file</span> Upload TXT Message File:</label>
  <input type="file" id="fileInput" class="form-control" accept=".txt">

  <label for="speed"><span class="material-icons">speed</span> Speed (Seconds):</label>
  <input type="number" id="speed" class="form-control" min="1" value="1">

  <input type="submit" id="sendBtn" class="btn btn-success" value="🚀 Start Sending">
  <button id="stopBtn" class="stop-btn btn">🛑 Stop</button>

  <script src="popup.js"></script>
</body>
</html>
EOF

# popup.js
cat > extension/popup.js << 'EOF'
document.getElementById('fileInput').addEventListener('change', function(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = function(e) {
        window.uploadedMessages = e.target.result.split("\n").filter(line => line.trim() !== "");
    };
    if (file) reader.readAsText(file);
});

document.getElementById('sendBtn').addEventListener('click', function () {
    const haterName = document.getElementById('HatersName').value.trim();
    const speed = parseInt(document.getElementById('speed').value, 10) * 1000;
    const messages = window.uploadedMessages || [];

    if (!haterName) {
        alert("Please enter Hater's Name");
        return;
    }
    
    if (!messages.length) {
        alert("Please upload a TXT file with messages");
        return;
    }

    chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
        chrome.scripting.executeScript({
            target: { tabId: tabs[0].id },
            files: ["content_script.js"]
        }, () => {
            chrome.tabs.sendMessage(tabs[0].id, { messages, speed, haterName });
        });
    });
});

document.getElementById('stopBtn').addEventListener('click', function () {
    chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
        chrome.tabs.sendMessage(tabs[0].id, { stop: true });
    });
});
EOF

# Create main web interface
echo "🌐 Creating web interface..."
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instagram Message Bot - Render</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #2c3e50;
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        .status-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
            border-left: 5px solid #28a745;
        }
        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s ease;
            margin: 5px;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary {
            background: #007bff;
            color: white;
        }
        .btn-primary:hover {
            background: #0056b3;
            transform: translateY(-2px);
        }
        .btn-success {
            background: #28a745;
            color: white;
        }
        .btn-success:hover {
            background: #218838;
            transform: translateY(-2px);
        }
        .instructions {
            background: #e9ecef;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .step {
            margin: 15px 0;
            padding-left: 20px;
            border-left: 3px solid #007bff;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Instagram Message Bot</h1>
            <p>Deployed on Render - Ready to Use!</p>
        </div>
        
        <div class="status-card">
            <strong>Status:</strong> <span id="status">Loading...</span>
        </div>
        
        <div class="instructions">
            <h3>📖 How to Use:</h3>
            <div class="step">
                <strong>Step 1:</strong> Download the Chrome Extension
            </div>
            <div class="step">
                <strong>Step 2:</strong> Go to <code>chrome://extensions/</code>
            </div>
            <div class="step">
                <strong>Step 3:</strong> Enable "Developer mode"
            </div>
            <div class="step">
                <strong>Step 4:</strong> Click "Load unpacked" and select the extension folder
            </div>
            <div class="step">
                <strong>Step 5:</strong> Go to Instagram and use the extension!
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 30px;">
            <a href="/extension/manifest.json" class="btn btn-success" download="manifest.json">
                📥 Download Extension Files
            </a>
            <button class="btn btn-primary" onclick="checkStatus()">
                🔄 Check Status
            </button>
        </div>
        
        <div id="file-list" style="margin-top: 30px;">
            <h4>📁 Available Extension Files:</h4>
            <ul id="files"></ul>
        </div>
    </div>

    <script>
        async function checkStatus() {
            try {
                const response = await fetch('/api/status');
                const data = await response.json();
                document.getElementById('status').innerHTML = 
                    `<span style="color: green;">🟢 ${data.status} - ${data.service} v${data.version}</span>`;
            } catch (error) {
                document.getElementById('status').innerHTML = 
                    '<span style="color: red;">🔴 Offline - Check connection</span>';
            }
        }
        
        // Load available files
        async function loadFiles() {
            const files = ['manifest.json', 'background.js', 'content_script.js', 'popup.html', 'popup.js'];
            const filesList = document.getElementById('files');
            
            files.forEach(file => {
                const li = document.createElement('li');
                const link = document.createElement('a');
                link.href = `/extension/${file}`;
                link.textContent = file;
                link.download = file;
                link.style.color = '#007bff';
                link.style.textDecoration = 'none';
                
                li.appendChild(link);
                filesList.appendChild(li);
            });
        }
        
        // Initialize
        checkStatus();
        loadFiles();
    </script>
</body>
</html>
EOF

echo "✅ Build completed successfully!"
echo "📁 Extension files created in /extension directory"
echo "🌐 Web interface created in /public directory"
echo "🚀 Ready for deployment on Render!"

# Make script executable
chmod +x build.sh
