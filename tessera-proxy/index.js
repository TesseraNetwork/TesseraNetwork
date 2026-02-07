// tessera-proxy/index.js
require('dotenv').config();
const express = require('express');
const fetch = require('node-fetch');

const app = express();
const PORT = process.env.PORT || 3000;
const TESSERA_BASE_URL = process.env.TESSERA_BASE_URL;
const TESSERA_API_KEY = process.env.TESSERA_API_KEY;

// Middleware to parse JSON bodies
app.use(express.json());
// Middleware to handle URL-encoded data
app.use(express.urlencoded({ extended: true }));

// Generic proxy route for all Tessera API endpoints
app.use('/api/tessera', async (req, res) => {
    // req.originalUrl includes the full path and query string, e.g., "/api/tessera/Block?limit=5"
    // We need to remove "/api/tessera" from the start
    const proxyPath = '/api/tessera';
    const targetPathWithQuery = req.originalUrl.startsWith(proxyPath)
                                ? req.originalUrl.substring(proxyPath.length)
                                : req.originalUrl;
    // Ensure we handle the case where targetPathWithQuery might be empty or just a '/'
    const targetPath = targetPathWithQuery.startsWith('/') ? targetPathWithQuery.substring(1) : targetPathWithQuery;
    const targetUrl = `${TESSERA_BASE_URL}/${targetPath}`;

    // Construct the request options for node-fetch
    const options = {
        method: req.method,
        headers: {
            'Content-Type': req.headers['content-type'] || 'application/json',
            'api_key': TESSERA_API_KEY, // Add the API key securely from the server
        },
    };

    // If there's a request body, add it to the options
    if (req.method !== 'GET' && req.method !== 'HEAD') {
        options.body = JSON.stringify(req.body);
    }

    try {
        const response = await fetch(targetUrl, options);

        // Forward the status and headers from the Tessera API response
        res.status(response.status);
        for (const [key, value] of response.headers.entries()) {
            if (key !== 'content-encoding') { // Avoid issues with compressed content
                res.setHeader(key, value);
            }
        }

        // Stream the response body back to the client
        response.body.pipe(res);
    } catch (error) {
        console.error('Proxy error:', error);
        res.status(500).json({ error: 'Internal proxy error', details: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`Tessera API Proxy listening on port ${PORT}`);
    console.log(`Proxying requests to ${TESSERA_BASE_URL}`);
});
