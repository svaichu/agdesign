#!/bin/bash

# Syson Runner Script
# This script helps you run Syson with your SysML model

set -e

SYSON_DIR="/teamspace/studios/this_studio/syson"
AGDESIGN_DIR="/teamspace/studios/this_studio/agdesign"
SYSON_MODEL="$AGDESIGN_DIR/new.sysml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Syson Runner ===${NC}"
echo "SysML Model: $SYSON_MODEL"
echo ""

# Check if containers are already running
DB_RUNNING=$(docker ps -q -f name=syson-db)
APP_RUNNING=$(docker ps -q -f name=syson-app)

if [ ! -z "$DB_RUNNING" ] && [ ! -z "$APP_RUNNING" ]; then
    echo -e "${GREEN}✓ Syson is already running${NC}"
else
    echo -e "${YELLOW}Starting Syson containers...${NC}"
    
    # Stop and remove existing containers if they exist
    docker stop syson-db syson-app 2>/dev/null || true
    docker rm syson-db syson-app 2>/dev/null || true
    
    # Start database
    echo "Starting PostgreSQL database..."
    docker run -d --name syson-db \
        -e POSTGRES_DB=postgres \
        -e POSTGRES_USER=username \
        -e POSTGRES_PASSWORD=password \
        postgres:15
    
    sleep 3
    
    # Start Syson app
    echo "Starting Syson application..."
    docker run -d --name syson-app \
        -p 8080:8080 \
        -v /teamspace/studios/this_studio/agdesign:/agdesign:ro \
        --link syson-db:database \
        -e SPRING_DATASOURCE_URL=jdbc:postgresql://database/postgres \
        -e SPRING_DATASOURCE_USERNAME=username \
        -e SPRING_DATASOURCE_PASSWORD=password \
        eclipsesyson/syson:v2025.10.0
    
    sleep 5
    echo -e "${GREEN}✓ Syson containers started${NC}"
fi

echo ""
echo -e "${GREEN}Syson is running at: http://localhost:8080${NC}"
echo ""
echo "Next steps:"
echo "1. Open http://localhost:8080 in your browser"
echo "2. Create a new project or import your SysML model"
echo "3. Load your SysML file: $SYSON_MODEL"
echo ""
echo "To stop Syson, run:"
echo "  docker stop syson-app syson-db"
echo ""
echo "To remove Syson containers, run:"
echo "  docker rm syson-app syson-db"
