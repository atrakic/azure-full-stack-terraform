# custom (e.g. 2s)
# docker build --build-arg REFRESH_INTERVAL=2000 --build-arg API_URI=http://api:3000 .

FROM nginxinc/nginx-unprivileged:1.27-alpine
WORKDIR /usr/share/nginx/html

ARG API_URI=http://api:3000
ENV API_URI ${API_URI}

ARG REFRESH_INTERVAL=5000
ENV REFRESH_INTERVAL ${REFRESH_INTERVAL}

USER root

# create robots and humans files
COPY <<robots.txt <<humans.txt /usr/share/nginx/html/
User-agent: *
Disallow:
robots.txt
aTrakic (Full Stack developer) 
https://atrakic.github.io/
@atrakic
humans.txt

COPY <<EOF index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>System Information Dashboard</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.1.3/dist/css/bootstrap.min.css">
    <style>
        .info-row.odd  { background-color: #e8f4fd; }
        .info-row.even { background-color: #ffffff; }
        .info-value    { color: #0a6640; font-family: monospace; }
    </style>
</head>
<body class="bg-light">
  <main class="container py-4" style="max-width:800px">
    <h1 class="text-center text-dark mb-4">🖥️ System Information Dashboard</h1>
    <div id="systemInfo" class="card shadow-sm">
        <div class="card-body">
            <p class="text-muted text-center">Fetching system information...</p>
        </div>
    </div>
  </main>
  <script src="sysinfo.js"></script>
</body>
</html>
EOF

RUN <<EOF cat > sysinfo.js
function formatValue(key, val) {
    if (key === 'timestamp') return new Date(val).toLocaleString();
    if (typeof val === 'number') return val % 1 !== 0 ? val.toFixed(2) : val;
    return val;
}
function continuousFetch(url) {
    function doFetch() {
        fetch(url)
            .then(response => response.json())
            .then(data => {
                const htmlContent = Object.entries(data)
                    .map(([key, val], i) => {
                        const parity = i % 2 === 0 ? 'odd' : 'even';
                        const label = key.replace(/_/g, ' ');
                        const value = formatValue(key, val);
                        return '<div class="info-row ' + parity + ' d-flex justify-content-between px-3 py-2 rounded mb-1">'
                            + '<span class="font-weight-bold text-dark text-capitalize">' + label + '</span>'
                            + '<span class="info-value">' + value + '</span>'
                            + '</div>';
                    }).join('');
                document.querySelector("#systemInfo").innerHTML = htmlContent;
            })
            .catch(error => {
                const infoDiv = document.getElementById('systemInfo');
                infoDiv.innerHTML = '<p style="color:red;">Error loading system information: ' + error.message + '</p>';
                console.error('Fetch error:', error);
            });
    }
    doFetch();
    setInterval(doFetch, ${REFRESH_INTERVAL});
}
continuousFetch('/api');
EOF

# Configure Nginx to serve the static file
RUN <<EOF cat > /etc/nginx/conf.d/default.conf
server {
    listen 8080;
    server_name ${NGINX_SERVER_NAME:-localhost};

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files \$uri \$uri/ =404;
    }

    # Enable CORS for API calls
    location /api {
        proxy_pass ${API_URI};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;

        # CORS headers
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
    }
}
EOF

HEALTHCHECK --interval=10s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:8080/api || exit 1

USER nginx
