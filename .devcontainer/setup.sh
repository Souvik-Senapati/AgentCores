#!/bin/bash
# AgentCores Codespaces Setup Script
set -e

echo "🚀 Setting up AgentCores development environment..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update -y

# Install required system dependencies
echo "🔧 Installing system dependencies..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    python3-pip \
    python3-venv

# Verify installations
echo "✅ Verifying installations..."
echo "Node.js version: $(node --version || echo 'Not installed here, using Codespaces feature')"
echo "npm version: $(npm --version || echo 'Not installed here, using Codespaces feature')"
echo "Python version: $(python3 --version)"
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"

# Set up Python environment
echo "🐍 Setting up Python environment..."
python3 -m pip install --upgrade pip
pip3 install -r backend/requirements.txt

# Set up frontend environment
echo "⚛️  Setting up Frontend environment..."
cd frontend
npm install
cd ..

# Create environment files from templates
echo "📝 Creating environment files..."
if [ ! -f backend/.env ]; then
    cp backend/.env.example backend/.env
    echo "✅ Created backend/.env from template"
fi

# Set proper permissions
echo "🔐 Setting permissions..."
chmod +x .devcontainer/setup.sh || true
chmod +x *.bat || true

# Create workspace scripts
echo "📜 Creating workspace scripts..."

# Start script
cat > start-codespace.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting AgentCores in GitHub Codespaces..."

docker compose up -d

echo "⏳ Waiting for services to start..."
sleep 10

echo "🏥 Checking service health..."
curl -f http://localhost:8000/health || echo "❌ Backend not ready yet"
curl -f http://localhost:3000 || echo "❌ Frontend not ready yet"

echo ""
echo "🎉 AgentCores is starting up!"
echo "Frontend: https://$CODESPACE_NAME-3000.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
echo "Backend API: https://$CODESPACE_NAME-8000.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
EOF
chmod +x start-codespace.sh

# Stop script
cat > stop-codespace.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping AgentCores services..."
docker compose down
echo "✅ All services stopped"
EOF
chmod +x stop-codespace.sh

echo ""
echo "🎉 Setup complete!"
echo "🚀 Run './start-codespace.sh' to start the application"
echo "📖 Check CODESPACES_GUIDE.md for usage instructions"
