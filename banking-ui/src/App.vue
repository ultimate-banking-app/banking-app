<template>
  <div id="app">
    <header class="header">
      <div class="container">
        <h1>🏦 Banking Application</h1>
        <nav v-if="isAuthenticated">
          <button @click="logout" class="btn btn-secondary">Logout ({{ user.username }})</button>
        </nav>
      </div>
    </header>

    <main class="main">
      <div class="container">
        <!-- Login Form -->
        <div v-if="!isAuthenticated" class="login-section">
          <div class="card">
            <h2>Login to Your Account</h2>
            <form @submit.prevent="login">
              <div class="form-group">
                <label>Username:</label>
                <input v-model="loginForm.username" type="text" required class="form-control">
              </div>
              <div class="form-group">
                <label>Password:</label>
                <input v-model="loginForm.password" type="password" required class="form-control">
              </div>
              <button type="submit" :disabled="loading" class="btn btn-primary">
                {{ loading ? 'Logging in...' : 'Login' }}
              </button>
            </form>
            <div class="demo-credentials">
              <h4>Demo Credentials:</h4>
              <p><strong>john.doe</strong> / password</p>
              <p><strong>jane.smith</strong> / password</p>
              <p><strong>admin</strong> / password</p>
            </div>
          </div>
        </div>

        <!-- Dashboard -->
        <div v-if="isAuthenticated" class="dashboard">
          <!-- Navigation Tabs -->
          <div class="tabs">
            <button @click="activeTab = 'accounts'" :class="{ active: activeTab === 'accounts' }" class="tab-btn">
              💰 Accounts
            </button>
            <button @click="activeTab = 'transactions'" :class="{ active: activeTab === 'transactions' }" class="tab-btn">
              📊 Transactions
            </button>
            <button @click="activeTab = 'deposit'" :class="{ active: activeTab === 'deposit' }" class="tab-btn">
              📥 Deposit
            </button>
            <button @click="activeTab = 'withdrawal'" :class="{ active: activeTab === 'withdrawal' }" class="tab-btn">
              📤 Withdrawal
            </button>
            <button @click="activeTab = 'transfer'" :class="{ active: activeTab === 'transfer' }" class="tab-btn">
              🔄 Transfer
            </button>
            <button @click="activeTab = 'audit'" :class="{ active: activeTab === 'audit' }" class="tab-btn">
              📋 Audit Logs
            </button>
          </div>

          <!-- Accounts Tab -->
          <div v-if="activeTab === 'accounts'" class="tab-content">
            <h2>Your Accounts</h2>
            <div class="accounts-grid">
              <div v-for="account in accounts" :key="account.id" class="account-card">
                <h3>{{ account.accountType }} Account</h3>
                <p class="account-number">{{ account.accountNumber }}</p>
                <p class="balance">${{ account.balance.toFixed(2) }}</p>
                <p class="status">Status: {{ account.status }}</p>
              </div>
            </div>
          </div>

          <!-- Transactions Tab -->
          <div v-if="activeTab === 'transactions'" class="tab-content">
            <h2>Transaction History</h2>
            <div class="transactions-list">
              <div v-for="transaction in transactions" :key="transaction.id" class="transaction-item">
                <div class="transaction-info">
                  <span class="transaction-type">{{ transaction.type }}</span>
                  <span class="transaction-amount">${{ transaction.amount.toFixed(2) }}</span>
                  <span class="transaction-date">{{ formatDate(transaction.createdAt) }}</span>
                </div>
                <p class="transaction-description">{{ transaction.description }}</p>
              </div>
            </div>
          </div>

          <!-- Deposit Tab -->
          <div v-if="activeTab === 'deposit'" class="tab-content">
            <h2>Make a Deposit</h2>
            <div class="card">
              <form @submit.prevent="makeDeposit">
                <div class="form-group">
                  <label>Select Account:</label>
                  <select v-model="depositForm.accountId" required class="form-control">
                    <option value="">Select an account</option>
                    <option v-for="account in accounts" :key="account.id" :value="account.id">
                      {{ account.accountType }} - {{ account.accountNumber }}
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label>Amount:</label>
                  <input v-model.number="depositForm.amount" type="number" step="0.01" min="0.01" required class="form-control">
                </div>
                <div class="form-group">
                  <label>Description:</label>
                  <input v-model="depositForm.description" type="text" class="form-control">
                </div>
                <button type="submit" :disabled="loading" class="btn btn-primary">
                  {{ loading ? 'Processing...' : 'Make Deposit' }}
                </button>
              </form>
            </div>
          </div>

          <!-- Withdrawal Tab -->
          <div v-if="activeTab === 'withdrawal'" class="tab-content">
            <h2>Make a Withdrawal</h2>
            <div class="card">
              <form @submit.prevent="makeWithdrawal">
                <div class="form-group">
                  <label>Select Account:</label>
                  <select v-model="withdrawalForm.accountId" required class="form-control">
                    <option value="">Select an account</option>
                    <option v-for="account in accounts" :key="account.id" :value="account.id">
                      {{ account.accountType }} - {{ account.accountNumber }} (Balance: ${{ account.balance.toFixed(2) }})
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label>Amount:</label>
                  <input v-model.number="withdrawalForm.amount" type="number" step="0.01" min="0.01" required class="form-control">
                </div>
                <div class="form-group">
                  <label>Description:</label>
                  <input v-model="withdrawalForm.description" type="text" class="form-control">
                </div>
                <button type="submit" :disabled="loading" class="btn btn-primary">
                  {{ loading ? 'Processing...' : 'Make Withdrawal' }}
                </button>
              </form>
            </div>
          </div>

          <!-- Transfer Tab -->
          <div v-if="activeTab === 'transfer'" class="tab-content">
            <h2>Transfer Funds</h2>
            <div class="card">
              <form @submit.prevent="makeTransfer">
                <div class="form-group">
                  <label>From Account:</label>
                  <select v-model="transferForm.fromAccountId" required class="form-control">
                    <option value="">Select source account</option>
                    <option v-for="account in accounts" :key="account.id" :value="account.id">
                      {{ account.accountType }} - {{ account.accountNumber }} (Balance: ${{ account.balance.toFixed(2) }})
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label>To Account:</label>
                  <select v-model="transferForm.toAccountId" required class="form-control">
                    <option value="">Select destination account</option>
                    <option v-for="account in accounts" :key="account.id" :value="account.id">
                      {{ account.accountType }} - {{ account.accountNumber }}
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label>Amount:</label>
                  <input v-model.number="transferForm.amount" type="number" step="0.01" min="0.01" required class="form-control">
                </div>
                <div class="form-group">
                  <label>Description:</label>
                  <input v-model="transferForm.description" type="text" class="form-control">
                </div>
                <button type="submit" :disabled="loading" class="btn btn-primary">
                  {{ loading ? 'Processing...' : 'Transfer Funds' }}
                </button>
              </form>
            </div>
          </div>

          <!-- Audit Tab -->
          <div v-if="activeTab === 'audit'" class="tab-content">
            <h2>Audit Logs</h2>
            <div class="audit-list">
              <div v-for="log in auditLogs" :key="log.id" class="audit-item">
                <div class="audit-info">
                  <span class="audit-action">{{ log.action }}</span>
                  <span class="audit-resource">{{ log.resource }}</span>
                  <span class="audit-status">{{ log.status }}</span>
                  <span class="audit-date">{{ formatDate(log.createdAt) }}</span>
                </div>
                <p class="audit-details">{{ log.details }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Messages -->
        <div v-if="message" :class="['message', messageType]">
          {{ message }}
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'BankingApp',
  data() {
    return {
      isAuthenticated: false,
      user: null,
      token: null,
      loading: false,
      message: '',
      messageType: 'info',
      activeTab: 'accounts',
      
      loginForm: {
        username: '',
        password: ''
      },
      
      accounts: [],
      transactions: [],
      auditLogs: [],
      
      depositForm: {
        accountId: '',
        amount: '',
        description: ''
      },
      
      withdrawalForm: {
        accountId: '',
        amount: '',
        description: ''
      },
      
      transferForm: {
        fromAccountId: '',
        toAccountId: '',
        amount: '',
        description: ''
      }
    }
  },
  
  mounted() {
    // Check for existing token
    const token = localStorage.getItem('token')
    if (token) {
      this.token = token
      this.isAuthenticated = true
      this.user = JSON.parse(localStorage.getItem('user') || '{}')
      this.setupAxiosInterceptors()
      this.loadDashboardData()
    }
  },
  
  methods: {
    setupAxiosInterceptors() {
      axios.defaults.baseURL = 'http://localhost:8090'
      axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`
    },
    
    async login() {
      this.loading = true
      this.message = ''
      
      try {
        const response = await axios.post('/api/auth/login', this.loginForm)
        
        this.token = response.data.token
        this.user = response.data.user
        this.isAuthenticated = true
        
        localStorage.setItem('token', this.token)
        localStorage.setItem('user', JSON.stringify(this.user))
        
        this.setupAxiosInterceptors()
        await this.loadDashboardData()
        
        this.showMessage('Login successful!', 'success')
      } catch (error) {
        this.showMessage(error.response?.data?.message || 'Login failed', 'error')
      } finally {
        this.loading = false
      }
    },
    
    logout() {
      this.isAuthenticated = false
      this.user = null
      this.token = null
      this.accounts = []
      this.transactions = []
      this.auditLogs = []
      
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      
      delete axios.defaults.headers.common['Authorization']
      
      this.showMessage('Logged out successfully', 'info')
    },
    
    async loadDashboardData() {
      try {
        await Promise.all([
          this.loadAccounts(),
          this.loadTransactions(),
          this.loadAuditLogs()
        ])
      } catch (error) {
        this.showMessage('Failed to load dashboard data', 'error')
      }
    },
    
    async loadAccounts() {
      try {
        const response = await axios.get('/api/accounts')
        this.accounts = response.data
      } catch (error) {
        console.error('Failed to load accounts:', error)
      }
    },
    
    async loadTransactions() {
      try {
        const response = await axios.get('/api/accounts/transactions')
        this.transactions = response.data
      } catch (error) {
        console.error('Failed to load transactions:', error)
      }
    },
    
    async loadAuditLogs() {
      try {
        const response = await axios.get('/api/audit/logs')
        this.auditLogs = response.data.content || []
      } catch (error) {
        console.error('Failed to load audit logs:', error)
      }
    },
    
    async makeDeposit() {
      this.loading = true
      
      try {
        await axios.post('/api/deposits', {
          accountId: this.depositForm.accountId,
          amount: this.depositForm.amount,
          description: this.depositForm.description || 'Deposit via web'
        })
        
        this.showMessage('Deposit successful!', 'success')
        this.depositForm = { accountId: '', amount: '', description: '' }
        await this.loadDashboardData()
      } catch (error) {
        this.showMessage(error.response?.data?.message || 'Deposit failed', 'error')
      } finally {
        this.loading = false
      }
    },
    
    async makeWithdrawal() {
      this.loading = true
      
      try {
        await axios.post('/api/withdrawals', {
          accountId: this.withdrawalForm.accountId,
          amount: this.withdrawalForm.amount,
          description: this.withdrawalForm.description || 'Withdrawal via web'
        })
        
        this.showMessage('Withdrawal successful!', 'success')
        this.withdrawalForm = { accountId: '', amount: '', description: '' }
        await this.loadDashboardData()
      } catch (error) {
        this.showMessage(error.response?.data?.message || 'Withdrawal failed', 'error')
      } finally {
        this.loading = false
      }
    },
    
    async makeTransfer() {
      this.loading = true
      
      try {
        await axios.post('/api/transfers', {
          fromAccountId: this.transferForm.fromAccountId,
          toAccountId: this.transferForm.toAccountId,
          amount: this.transferForm.amount,
          description: this.transferForm.description || 'Transfer via web'
        })
        
        this.showMessage('Transfer successful!', 'success')
        this.transferForm = { fromAccountId: '', toAccountId: '', amount: '', description: '' }
        await this.loadDashboardData()
      } catch (error) {
        this.showMessage(error.response?.data?.message || 'Transfer failed', 'error')
      } finally {
        this.loading = false
      }
    },
    
    showMessage(text, type = 'info') {
      this.message = text
      this.messageType = type
      setTimeout(() => {
        this.message = ''
      }, 5000)
    },
    
    formatDate(dateString) {
      return new Date(dateString).toLocaleString()
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background-color: #f5f5f5;
}

.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 1rem 0;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header .container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header h1 {
  font-size: 1.8rem;
  font-weight: 600;
}

.main {
  padding: 2rem 0;
  min-height: calc(100vh - 80px);
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

.card {
  background: white;
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
}

.login-section {
  max-width: 400px;
  margin: 0 auto;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #333;
}

.form-control {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.form-control:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary {
  background: #667eea;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #5a6fd8;
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.demo-credentials {
  margin-top: 2rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 4px;
}

.demo-credentials h4 {
  margin-bottom: 0.5rem;
  color: #495057;
}

.tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  border-bottom: 1px solid #ddd;
}

.tab-btn {
  padding: 0.75rem 1rem;
  border: none;
  background: none;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: all 0.2s;
}

.tab-btn.active {
  border-bottom-color: #667eea;
  color: #667eea;
  font-weight: 500;
}

.tab-btn:hover {
  background: #f8f9fa;
}

.accounts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
}

.account-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  border-left: 4px solid #667eea;
}

.account-card h3 {
  color: #333;
  margin-bottom: 0.5rem;
}

.account-number {
  color: #666;
  font-family: monospace;
  margin-bottom: 0.5rem;
}

.balance {
  font-size: 1.5rem;
  font-weight: 600;
  color: #28a745;
  margin-bottom: 0.5rem;
}

.status {
  color: #666;
  font-size: 0.9rem;
}

.transactions-list, .audit-list {
  max-height: 500px;
  overflow-y: auto;
}

.transaction-item, .audit-item {
  background: white;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.transaction-info, .audit-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.transaction-type, .audit-action {
  font-weight: 500;
  color: #333;
}

.transaction-amount {
  font-weight: 600;
  color: #28a745;
}

.transaction-date, .audit-date {
  color: #666;
  font-size: 0.9rem;
}

.audit-status {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  background: #28a745;
  color: white;
}

.message {
  padding: 1rem;
  border-radius: 4px;
  margin: 1rem 0;
  font-weight: 500;
}

.message.success {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.message.error {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.message.info {
  background: #d1ecf1;
  color: #0c5460;
  border: 1px solid #bee5eb;
}

@media (max-width: 768px) {
  .header .container {
    flex-direction: column;
    gap: 1rem;
  }
  
  .tabs {
    flex-wrap: wrap;
  }
  
  .accounts-grid {
    grid-template-columns: 1fr;
  }
  
  .transaction-info, .audit-info {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
}
</style>
