#!/bin/bash

# Setup script for organized Laravel LAMP Stack deployment
echo "🔧 Setting up Laravel LAMP Stack deployment..."

# Make main script executable
chmod +x deploy.sh

# Make all scripts in scripts directory executable
chmod +x scripts/*.sh

# Set proper permissions for SSH key
chmod 600 config/my-local-key.pem 2>/dev/null || true

echo "✅ Setup complete!"
echo ""
echo "📁 Organized structure:"
echo "  📁 scripts/     - All deployment scripts"
echo "  📁 docs/        - Documentation files"
echo "  📁 config/      - Configuration files"
echo "  📁 laravel/     - Laravel application"
echo ""
echo "🚀 Ready to deploy:"
echo "  ./deploy.sh                 - Main deployment interface"
echo ""
echo "📖 Documentation:"
echo "  PROJECT-README.md           - Main documentation"
echo "  docs/QUICK-START.md         - Quick start guide"
echo "  docs/EC2-DEPLOYMENT-README.md - Detailed guide"
