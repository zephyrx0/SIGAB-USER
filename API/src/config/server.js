const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const setupServer = () => {
  const app = express();
  
  // Middleware
  app.use(cors());
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: true }));
  
  return app;
};

module.exports = { setupServer };