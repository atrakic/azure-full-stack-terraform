# Example web app
FROM golang:1.23-alpine AS builder
WORKDIR /src

# Use heredoc to create a simple system info webserver
RUN <<EOF cat > main.go
package main

import (
    "encoding/json"
    "log"
    "net/http"
    "runtime"
    "os"
    "time"

    httpSwagger "github.com/swaggo/http-swagger"
)

// @title System Info API
// @version 1.0
// @description A simple API to get system information
// @host localhost:3000
// @BasePath /
type SystemInfo struct {
    Hostname        string    \`json:"hostname"\`
    GoVersion       string    \`json:"go_version"\`
    OS              string    \`json:"os"\`
    Arch            string    \`json:"arch"\`
    CPUCores        int       \`json:"cpu_cores"\`
    MemoryAllocated float64   \`json:"memory_mb"\`
    Timestamp       time.Time \`json:"timestamp"\`
}

func getSystemInfo() SystemInfo {
    hostname, _ := os.Hostname()

    var m runtime.MemStats
    runtime.ReadMemStats(&m)

    return SystemInfo{
        Hostname:        hostname,
        GoVersion:       runtime.Version(),
        OS:              runtime.GOOS,
        Arch:            runtime.GOARCH,
        CPUCores:        runtime.NumCPU(),
        MemoryAllocated: float64(m.Alloc) / 1024 / 1024,
        Timestamp:       time.Now(),
    }
}

// @Summary Get system information
// @Description Get detailed system information including hostname, Go version, OS, architecture, CPU cores, and memory usage
// @Description Retrieve information about a system
// @Tags system
// @Accept json
// @Produce json
// @Success 200 {object} SystemInfo
// @Router / [get]
func systemInfoHandler(w http.ResponseWriter, r *http.Request) {
    sysInfo := getSystemInfo()

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(sysInfo)
}

func main() {
    http.HandleFunc("/", systemInfoHandler)

    // Serve static files from docs directory
    http.Handle("/docs/", http.StripPrefix("/docs/", http.FileServer(http.Dir("./docs"))))

    // Serve Swagger UI at /swagger/
    http.Handle("/swagger/", httpSwagger.Handler(
        httpSwagger.URL("/docs/swagger.json"),
    ))

    log.Println("System Info Server starting on :3000")
    log.Println("Swagger documentation available at: http://localhost:3000/swagger/")
    log.Fatal(http.ListenAndServe(":3000", nil))
}
EOF

# Initialize Go module and download dependencies
RUN go mod init atrakic/api && go mod tidy

# Install swaggo CLI to generate swagger docs
RUN go install github.com/swaggo/swag/cmd/swag@latest

# Generate swagger documentation
RUN swag init --parseDependency --parseInternal --generalInfo main.go --output docs

RUN CGO_ENABLED=0 GOOS=linux go build \
    -a -installsuffix cgo \
    -o sysinfo main.go

FROM scratch AS final
WORKDIR /app
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /src/sysinfo .
COPY --from=builder /src/docs ./docs
USER nobody
EXPOSE 3000
ENTRYPOINT ["./sysinfo"]
