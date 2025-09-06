# Banking UI - Vue.js Frontend

A comprehensive Vue.js frontend for the Banking Application microservices.

## Features

- **Authentication**: Login with JWT tokens
- **Account Management**: View account details and balances
- **Payment History**: View transaction history
- **User Management**: Admin panel for user management
- **Service Monitoring**: Real-time service status dashboard
- **Responsive Design**: Mobile-friendly interface

## Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

## Access

- **Development**: http://localhost:3000
- **Login Credentials**:
  - Username: `john.doe`, Password: `password` (Customer)
  - Username: `jane.smith`, Password: `password` (Customer)
  - Username: `admin`, Password: `password` (Admin)

## Backend Services

The UI connects to these backend services:
- API Gateway: http://localhost:8090
- Auth Service: http://localhost:8081
- Account Service: http://localhost:8084
- Payment Service: http://localhost:8083

## Tech Stack

- **Vue 3**: Progressive JavaScript framework
- **Vite**: Fast build tool and dev server
- **Axios**: HTTP client for API calls
- **CSS3**: Modern styling with gradients and animations

## Features by Tab

### Accounts Tab
- View all user accounts
- Account balances and details
- Account type and status

### Payments Tab
- Transaction history
- Payment status tracking
- Amount and date information

### Users Tab (Admin Only)
- User management
- Role and status information
- User details

### Services Tab
- Real-time service health monitoring
- Direct links to health checks
- Swagger documentation links
