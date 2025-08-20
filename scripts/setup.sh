#!/bin/bash

# Simple setup script to make all scripts executable
echo "🔧 Setting up Laravel LAMP Stack deployment..."

# Make scripts executable
chmod +x *.sh
chmod 600 my-local-key.pem 2>/dev/null || true

echo "✅ Setup complete!"
echo ""
echo "🚀 Ready to deploy:"
echo "  ./run-all.sh                 - Interactive deployment menu"
echo "  ./deploy-laravel-to-ec2.sh   - Direct deployment"
echo ""
echo "📖 Documentation:"
echo "  README.md                    - Main documentation"
echo "  QUICK-START.md              - Quick start guide"
echo "  EC2-DEPLOYMENT-README.md    - Detailed guide"
