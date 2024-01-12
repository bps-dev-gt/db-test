/**
 * Simple run script for node, which enables to serve our static app as a website.
 * For development use only.
 */
console.info('Creating configuration..');
console.info(process.env.NODE_PATH);

// HTTP server configuration
const serverConf = {
    staticPage: 'index.html',
    uriScheme: 'http',
    hostname: 'localhost',
    port: 3000,
    rootDir: 'src/root',
    allowedExtensions: {
        css: 'text/css',
        gif: 'image/gif',
        html: 'text/html',
        jpeg: 'image/jpeg',
        jpg: 'image/jpeg',
        js: 'application/javascript',
        json: 'application/json',
        mp3: 'audio/mp3',
        png: 'image/png',
        xml: 'application/xml',
        woff2: 'font/woff2',
    }
}

const localFS = require('fs');
const nodeServer = require('http');
const nodePath = require('path');
const realpathRootFir = nodePath.normalize(nodePath.resolve(serverConf.rootDir));

const server = nodeServer.createServer((req, res) => {

    // Build request root using URL object to strip query params
    let serverUrl = new URL(`${serverConf.uriScheme}://${serverConf.hostname}:${serverConf.port}${req.url}`);
    let requestPath = decodeURI(serverUrl.pathname);

    // Display request root
    console.info(`${req.method} ${requestPath}`);

    // Subtract extension
    const extension = nodePath.extname(requestPath).slice(1);
    const type = extension ? serverConf.allowedExtensions[extension] : serverConf.allowedExtensions.html;
    const supportedExtension = Boolean(type);

    // Validate extension
    if (!supportedExtension) {
        res.writeHead(404, {'Content-Type': 'text/html'});
        res.end('404: File not found');
        return;
    }

    // Process request root
    let fileName = requestPath;
    if (req.url === '/') fileName = serverConf.staticPage;
    else if (!extension) {
        try {
            localFS.accessSync(nodePath.join(realpathRootFir, requestPath + '.html'), localFS.constants.F_OK);
            fileName = requestPath + '.html';
        } catch (e) {
            fileName = nodePath.join(requestPath, serverConf.staticPage);
        }
    }

    const filePath = nodePath.join(realpathRootFir, fileName);
    const isPathUnderRoot = nodePath.normalize(nodePath.resolve(filePath)).startsWith(realpathRootFir);

    // Disable access to outside of home directory
    if (!isPathUnderRoot) {
        res.writeHead(404, {'Content-Type': 'text/html'});
        res.end(`404: File not found. File: ${filePath}`);
        return;
    }

    // Return file content
    localFS.readFile(filePath, (err, data) => {
        if (err) {
            res.writeHead(404, {'Content-Type': 'text/html'});
            res.end(`404: File not found. File: ${filePath}`);
        } else {
            res.writeHead(200, {'Content-Type': type});
            res.end(data);
        }
    });
});

console.info('Initializing web server..');

// Start HTTP server
server.listen(serverConf.port, serverConf.hostname, () => {
    console.info(`Server running at ${serverConf.uriScheme}://${serverConf.hostname}:${serverConf.port}/`);
    console.info(`App: ${serverConf.uriScheme}://${serverConf.hostname}:${serverConf.port}/vui`);
});
