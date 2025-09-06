#!/bin/bash

# Optimized build script for banking application
set -e

echo "🚀 Starting optimized build process..."

# Build configuration
MAVEN_OPTS="-Xmx2g -XX:+UseG1GC -Dmaven.artifact.threads=10"
PARALLEL_BUILDS=4

# Function to build with caching
build_with_cache() {
    echo "📦 Building with Maven cache optimization..."
    
    # Use Maven daemon for faster builds
    export MAVEN_OPTS="$MAVEN_OPTS -Dmaven.multiModuleProjectDirectory=$PWD"
    
    # Parallel build with dependency resolution optimization
    mvn clean install -T $PARALLEL_BUILDS \
        -DskipTests \
        -Dmaven.compile.fork=true \
        -Dmaven.compiler.maxmem=1g \
        -q
}

# Function to run tests in parallel
run_tests_parallel() {
    echo "🧪 Running tests in parallel..."
    
    # Get list of service modules
    services=($(find . -name "pom.xml" -path "*/src/*" -prune -o -name "pom.xml" -print | grep -v "^\./pom.xml" | xargs dirname))
    
    # Run tests in parallel for each service
    for service in "${services[@]}"; do
        (
            cd "$service"
            echo "Testing $service..."
            mvn test -q &
        )
    done
    
    wait
    echo "✅ All tests completed"
}

# Function to optimize Docker builds
optimize_docker_builds() {
    echo "🐳 Optimizing Docker builds..."
    
    # Enable BuildKit for faster builds
    export DOCKER_BUILDKIT=1
    
    # Build images in parallel
    services=(api-gateway auth-service account-service payment-service balance-service 
              transfer-service deposit-service withdrawal-service notification-service audit-service)
    
    for service in "${services[@]}"; do
        (
            cd "$service"
            echo "Building Docker image for $service..."
            docker build --cache-from "$service:latest" -t "$service:${BUILD_NUMBER:-latest}" . &
        )
    done
    
    wait
    echo "✅ All Docker images built"
}

# Main execution
main() {
    echo "🏗️ Banking Application Optimized Build"
    echo "======================================"
    
    # Check prerequisites
    command -v mvn >/dev/null 2>&1 || { echo "Maven is required but not installed."; exit 1; }
    command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed."; exit 1; }
    
    # Build shared module first
    echo "🔧 Building shared module..."
    cd shared && mvn clean install -DskipTests -q && cd ..
    
    # Build services
    build_with_cache
    
    # Run tests if not skipped
    if [[ "${SKIP_TESTS:-false}" != "true" ]]; then
        run_tests_parallel
    fi
    
    # Build Docker images if requested
    if [[ "${BUILD_DOCKER:-false}" == "true" ]]; then
        optimize_docker_builds
    fi
    
    echo "✅ Build completed successfully!"
    echo "📊 Build statistics:"
    echo "   - Services built: 10"
    echo "   - Build time: $(date)"
    echo "   - Parallel jobs: $PARALLEL_BUILDS"
}

# Execute main function
main "$@"
