FROM golang:1.23-alpine AS builder
WORKDIR /src

COPY <<hello.txt .
Hello, World!
hello.txt

RUN <<EOF cat > main.go
package main

import (
    "context"
    "encoding/json"
    "log"
    "net/http"
    "os"
    "os/signal"
    "runtime"
    "strings"
    "syscall"
    "time"

    httpSwagger "github.com/swaggo/http-swagger"
)

// @title System Info API
// @version 1.0
// @description A simple API to get system information
// @BasePath /api
type SystemInfo struct {
    Hostname        string    \`json:"hostname"\`
    GoVersion       string    \`json:"go_version"\`
    OS              string    \`json:"os"\`
    Arch            string    \`json:"arch"\`
    CPUCores        int       \`json:"cpu_cores"\`
    MemoryAllocated float64   \`json:"memory_mb"\`
    Timestamp       time.Time \`json:"timestamp"\`
    Env             map[string]string \`json:"env,omitempty"\`
}

func getEnv() map[string]string {
    env := make(map[string]string)
    for _, e := range os.Environ() {
        pair := strings.SplitN(e, "=", 2)
        if len(pair) == 2 {
            env[pair[0]] = pair[1]
        }
    }
    return env
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
        Env:             getEnv(),
    }
}

// @Summary Get system information
// @Description Get detailed system information including hostname, Go version, OS, architecture, CPU cores, and memory usage
// @Tags system
// @Accept json
// @Produce json
// @Success 200 {object} SystemInfo
// @Router /v1 [get]
func systemInfoHandler(w http.ResponseWriter, r *http.Request) {
    sysInfo := getSystemInfo()

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(sysInfo)
}

func main() {

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "text/plain")
        http.ServeFile(w, r, "hello.txt")
    })

    // @Summary Health check
    // @Tags system
    // @Produce plain
    // @Success 200 {string} string "OK"
    // @Router /health [get]
    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "text/plain")
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("OK"))
    })

    http.HandleFunc("/v1", systemInfoHandler)

    // Serve static files from docs directory
    http.Handle("/docs/", http.StripPrefix("/docs/", http.FileServer(http.Dir("./docs"))))

    // Serve Swagger UI at /swagger/
    http.Handle("/swagger/", httpSwagger.Handler(
        httpSwagger.URL("/docs/swagger.json"),
        httpSwagger.DeepLinking(true),
    ))

    srv := &http.Server{Addr: ":3000"}

    go func() {
        log.Println("System Info Server starting on :3000")
        log.Println("Swagger documentation available at: http://localhost:3000/swagger/")
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("listen: %s\n", err)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    log.Println("Shutting down server...")
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    if err := srv.Shutdown(ctx); err != nil {
        log.Fatalf("Server forced to shutdown: %v", err)
    }
    log.Println("Server exited")
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
COPY --from=builder /src/hello.txt .
COPY --from=builder /src/docs ./docs
USER nobody
EXPOSE 3000
ENTRYPOINT ["./sysinfo"]
