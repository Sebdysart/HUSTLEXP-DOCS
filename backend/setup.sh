#!/bin/bash
# =============================================================================
# HustleXP Backend Setup Script
# =============================================================================
# PURPOSE: Initialize development and test databases
# USAGE: ./setup.sh
# =============================================================================

set -e

echo "🚀 HustleXP Backend Setup"
echo "========================="

# Configuration
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
DEV_DB="hustlexp"
TEST_DB="hustlexp_test"

# Check for psql
if ! command -v psql &> /dev/null; then
    echo "❌ psql not found. Please install PostgreSQL."
    exit 1
fi

echo "📦 Installing dependencies..."
npm install

echo "🗄️  Setting up databases..."

# Create development database if not exists
echo "  Creating development database: $DEV_DB"
psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "SELECT 1 FROM pg_database WHERE datname = '$DEV_DB'" | grep -q 1 || \
    psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "CREATE DATABASE $DEV_DB"

# Create test database if not exists
echo "  Creating test database: $TEST_DB"
psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "SELECT 1 FROM pg_database WHERE datname = '$TEST_DB'" | grep -q 1 || \
    psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "CREATE DATABASE $TEST_DB"

# Apply schema to development database
echo "📐 Applying schema to development database..."
psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $DEV_DB -f ../schema.sql

# Apply schema to test database
echo "📐 Applying schema to test database..."
psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $TEST_DB -f ../schema.sql

# Verify schema version
echo "✅ Verifying schema version..."
VERSION=$(psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $DEV_DB -t -c "SELECT version FROM schema_versions ORDER BY applied_at DESC LIMIT 1" | xargs)
echo "   Schema version: $VERSION"

# Verify triggers exist
echo "✅ Verifying triggers..."
TRIGGER_COUNT=$(psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $DEV_DB -t -c "SELECT COUNT(*) FROM pg_trigger WHERE tgname LIKE '%terminal%' OR tgname LIKE '%xp_%' OR tgname LIKE '%escrow_%'" | xargs)
echo "   Triggers found: $TRIGGER_COUNT"

if [ "$TRIGGER_COUNT" -lt 5 ]; then
    echo "❌ Expected at least 5 invariant triggers, found $TRIGGER_COUNT"
    exit 1
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Run tests:        npm run test:invariants"
echo "   2. Start dev server: npm run dev"
echo ""
echo "📊 Database status:"
echo "   Development: postgresql://$POSTGRES_USER@$POSTGRES_HOST:$POSTGRES_PORT/$DEV_DB"
echo "   Test:        postgresql://$POSTGRES_USER@$POSTGRES_HOST:$POSTGRES_PORT/$TEST_DB"
