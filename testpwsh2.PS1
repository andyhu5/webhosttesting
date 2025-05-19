# # List of URLs to test
# $urls = @("google.com", "youtube.com", "facebook.com", "twitter.com", "instagram.com", "linkedin.com", "reddit.com", "pinterest.com", "tumblr.com", "x.com", "microsoft.com", "aws.com")

# # Measure execution time
# $executionTime = Measure-Command {
#     # Use ThreadJob for lightweight parallel execution
#     $jobs = $urls | ForEach-Object {
#         Start-ThreadJob -ScriptBlock {
#             param($url)
#             $result = Test-NetConnection -ComputerName $url -Port 443 -InformationLevel "Quiet"
#             [PSCustomObject]@{
#                 ComputerName    = $url
#                 RemotePort      = 443
#                 TcpTestSucceeded = $result
#             }
#         } -ArgumentList $_ -ThrottleLimit 12
#     }

#     # Collect results
#     $result = $jobs | Receive-Job -Wait -AutoRemoveJob | Sort-Object ComputerName

#     # Format and write results to file
#     $header = "{0,-20} {1,-10} {2,-15}" -f "ComputerName", "RemotePort", "TcpTestSucceeded"
#     $separator = "-" * 12 + "  " + "-" * 8 + " " + "-" * 16
#     $output = @($header, $separator)
#     foreach ($item in $result) {
#         $output += "{0,-20} {1,-10} {2,-15}" -f $item.ComputerName, $item.RemotePort, $item.TcpTestSucceeded
#     }
#     $output | Out-File -FilePath "testWebHostPwsh.txt" -Force
# }

# # Append execution time to file
# "" | Out-File -FilePath "testWebHostPwsh.txt" -Append
# "Execution Time: $($executionTime.TotalSeconds) seconds" | Out-File -FilePath "testWebHostPwsh.txt" -Append




$urls = @("google.com", "youtube.com", "facebook.com", "twitter.com", "instagram.com", "linkedin.com", "reddit.com", "pinterest.com", "tumblr.com", "x.com", "microsoft.com", "aws.com")

$executionTime = Measure-Command {
    $jobs = $urls | ForEach-Object {
        Start-ThreadJob -ScriptBlock {
            param($url)
            $client = New-Object System.Net.Sockets.TcpClient
            try {
                $result = $client.ConnectAsync($url, 443).Wait(500)
                "{0,-20} {1,-10} {2,-15}" -f $url, 443, $result
            }
            finally {
                $client.Dispose()
            }
        } -ArgumentList $_ -ThrottleLimit 12
    }

    $result = $jobs | Receive-Job -Wait -AutoRemoveJob | Sort-Object
    
    $header = "{0,-20} {1,-10} {2,-15}" -f "ComputerName", "RemotePort", "TcpTestSucceeded"
    $separator = "-" * 12 + "  " + "-" * 8 + " " + "-" * 16
    @($header, $separator) + $result | Out-File -FilePath "testWebHostPwsh.txt" -Force
}

"" | Out-File -FilePath "testWebHostPwsh.txt" -Append
"Execution Time: $($executionTime.TotalSeconds) seconds" | Out-File -FilePath "testWebHostPwsh.txt" -Append

