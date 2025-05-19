# List of URLs to test
$urls = @("google.com", "youtube.com", "facebook.com", "twitter.com", "instagram.com", "linkedin.com", "reddit.com", "pinterest.com", "tumblr.com", "x.com", "microsoft.com", "aws.com")

# Measure execution time
$executionTime = Measure-Command {
    $result = $urls | ForEach-Object -Parallel {
        # Testing web host and port 443
        Test-NetConnection -ComputerName $_ -Port 443 -InformationLevel "Detailed" | 
        Select-Object -Property ComputerName, RemotePort, TcpTestSucceeded
    } -ThrottleLimit 12

    # Write results to file
    $result | Out-File -FilePath "testWebHostPwsh.txt" -Force -Append
}

# Write execution time to file
"Execution Time: $($executionTime.TotalSeconds) seconds" | Out-File -FilePath "testWebHostPwsh.txt" -Append