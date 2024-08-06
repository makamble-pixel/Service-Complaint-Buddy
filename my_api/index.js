const express = require('express');
const bodyParser = require('body-parser');
const customerRoutes = require('./routes/customer');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());
app.use('/customers', customerRoutes);

app.listen(port,()=>{
    console.log(`Server is running on port ${port}`);
});