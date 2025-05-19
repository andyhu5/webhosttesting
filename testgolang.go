package main

import (
	"fmt"
	"net"
	"os"
	"strings"
	"sync"
	"time"
)

// Result struct to hold connection test results
type Result struct {
	ComputerName     string
	RemotePort       int
	TcpTestSucceeded bool
}

// testConnection tests TCP connection to a host on port 443
func testConnection(host string) Result {
	result := Result{
		ComputerName:     host,
		RemotePort:       443,
		TcpTestSucceeded: false,
	}

	// Attempt to connect with a 5-second timeout
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:443", host), 5*time.Second)
	if err == nil {
		result.TcpTestSucceeded = true
		conn.Close()
	}

	return result
}

func main() {
	// List of URLs to test
	urls := []string{
		"google.com", "youtube.com", "facebook.com", "twitter.com", "instagram.com",
		"linkedin.com", "reddit.com", "pinterest.com", "tumblr.com", "x.com",
		"microsoft.com", "aws.com",
	}

	// Record start time
	startTime := time.Now()

	// Channel to collect results
	results := make(chan Result, len(urls))
	// WaitGroup to synchronize goroutines
	var wg sync.WaitGroup
	// Semaphore to limit concurrency to 12
	sem := make(chan struct{}, 12)

	// Launch goroutines for each URL
	for _, url := range urls {
		wg.Add(1)
		sem <- struct{}{} // Acquire semaphore
		go func(u string) {
			defer wg.Done()
			defer func() { <-sem }() // Release semaphore
			results <- testConnection(u)
		}(url)
	}

	// Close results channel after all goroutines complete
	go func() {
		wg.Wait()
		close(results)
	}()

	// Collect results
	var collectedResults []Result
	for result := range results {
		collectedResults = append(collectedResults, result)
	}

	// Record end time and calculate duration
	endTime := time.Now()
	duration := endTime.Sub(startTime)

	// Write results to file
	file, err := os.Create("testWebHostGolang.txt")
	if err != nil {
		fmt.Printf("Error creating file: %v\n", err)
		return
	}
	defer file.Close()

	// Write header
	header := fmt.Sprintf("%-20s %-12s %-15s\n", "ComputerName", "RemotePort", "TcpTestSucceeded")
	if _, err := file.WriteString(header); err != nil {
		fmt.Printf("Error writing header: %v\n", err)
		return
	}
	if _, err := file.WriteString(strings.Repeat("-", 50) + "\n"); err != nil {
		fmt.Printf("Error writing separator: %v\n", err)
		return
	}

	// Write each result
	for _, result := range collectedResults {
		line := fmt.Sprintf("%-20s %-12d %-15t\n", result.ComputerName, result.RemotePort, result.TcpTestSucceeded)
		if _, err := file.WriteString(line); err != nil {
			fmt.Printf("Error writing result: %v\n", err)
			return
		}
	}

	// Write duration
	durationLine := fmt.Sprintf("\nExecution Duration: %.2f seconds\n", duration.Seconds())
	if _, err := file.WriteString(durationLine); err != nil {
		fmt.Printf("Error writing duration: %v\n", err)
		return
	}
}
