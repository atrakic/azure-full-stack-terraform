# Example:
# docker build \
#   --build-arg API_HOST=api:3000 \
#   --build-arg API_ENDPOINT=/api/v2 \
#   --build-arg CORS_ORIGIN=https://myapp.example.com .

FROM nginxinc/nginx-unprivileged:1.27-alpine
WORKDIR /usr/share/nginx/html

ARG API_HOST=api:3000
ARG API_ENDPOINT=/api/v1
ARG REFRESH_INTERVAL=5000
ARG CORS_ORIGIN

ENV API_HOST=${API_HOST} \
    REFRESH_INTERVAL=${REFRESH_INTERVAL} \
    CORS_ORIGIN=${CORS_ORIGIN} \
    API_ENDPOINT=${API_ENDPOINT}

USER root

COPY <<robots.txt <<developer.txt .
User-agent: *
Disallow:
robots.txt
aTrakic (Full Stack developer)
https://atrakic.github.io/
@atrakic
developer.txt

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
function formatScalar(key, val) {
    if (key === 'timestamp') return new Date(val).toLocaleString();
    if (typeof val === 'number') return val % 1 !== 0 ? val.toFixed(2) : String(val);
    return String(val);
}
function continuousFetch(url) {
    function doFetch() {
        fetch(url)
            .then(response => response.json())
            .then(data => {
                const container = document.querySelector('#systemInfo');
                container.textContent = '';
                Object.entries(data).forEach(([key, val], i) => {
                    const row = document.createElement('div');
                    row.className = 'info-row ' + (i % 2 === 0 ? 'odd' : 'even') + ' d-flex justify-content-between px-3 py-2 rounded mb-1';

                    const labelEl = document.createElement('span');
                    labelEl.className = 'font-weight-bold text-dark text-capitalize';
                    labelEl.textContent = key.replace(/_/g, ' ');

                    const valueEl = document.createElement('span');
                    valueEl.className = 'info-value';
                    if (val !== null && typeof val === 'object') {
                        const pre = document.createElement('pre');
                        pre.style.cssText = 'margin:0;font-size:0.8em';
                        pre.textContent = JSON.stringify(val, null, 2);
                        valueEl.appendChild(pre);
                    } else {
                        valueEl.textContent = formatScalar(key, val);
                    }

                    row.appendChild(labelEl);
                    row.appendChild(valueEl);
                    container.appendChild(row);
                });
            })
            .catch(error => {
                const container = document.getElementById('systemInfo');
                const p = document.createElement('p');
                p.style.color = 'red';
                p.textContent = 'Error loading system information: ' + error.message;
                container.textContent = '';
                container.appendChild(p);
                console.error('Fetch error:', error);
            });
    }
    doFetch();
    setInterval(doFetch, ${REFRESH_INTERVAL});
}
continuousFetch('${API_ENDPOINT}');
EOF

# Configure Nginx to serve the static file
RUN <<EOF cat > /etc/nginx/conf.d/default.conf
upstream api_upstream {
    # Disable passive health checking so nginx always attempts the upstream
    # regardless of previous failures
    server ${API_HOST} max_fails=0;
}

server {
    listen 8080;
    server_name _;

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files \$uri \$uri/ =404;
    }

    # Proxy /api/* to Go backend, stripping the /api prefix
    location /api/ {
        rewrite ^/api/(.*) /\$1 break;
        proxy_pass         http://api_upstream;

        # Required when proxying to Azure App Service HTTPS hostnames,
        # which need SNI to present the correct certificate.
        proxy_ssl_server_name on;

        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;

        # Add CORS headers if CORS_ORIGIN is set
$(if [ -n "${CORS_ORIGIN}" ]; then
    printf "        add_header 'Access-Control-Allow-Origin'  '${CORS_ORIGIN}' always;\n"
    printf "        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;\n"
    printf "        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;\n"
fi)
    }

    # Swagger UI fetches /docs/swagger.json as an absolute path from the browser
    location /docs/ {
        proxy_pass http://api_upstream;
        proxy_set_header Host \$host;
    }
}
EOF

HEALTHCHECK --interval=10s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:8080/api || exit 1

EXPOSE 8080
USER nginx
