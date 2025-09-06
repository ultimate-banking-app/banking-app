#!/bin/bash

echo "🛑 Stopping Banking Application Services..."

# Kill all Spring Boot services
pkill -f "spring-boot:run"
pkill -f python3

echo "✅ All services stopped."
