const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

// Health Check Endpoint for ALB / Target Group
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'HEALTHY',
    tier: 'Application (Logic) Tier',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/api/v1/accounts', (req, res) => {
  res.json({
    accounts: [
      { id: "ACC-98412", type: "Checking", balance: 54320.50, currency: "USD" },
      { id: "ACC-31049", type: "Savings", balance: 125000.00, currency: "USD" }
    ]
  });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`[INFO] Enterprise Banking Backend API running on port ${PORT}`);
  });
}

module.exports = app;
