import socket
import concurrent.futures
import time
from datetime import datetime

# List of URLs to test
urls = [
    "google.com", "youtube.com", "facebook.com", "twitter.com", "instagram.com",
    "linkedin.com", "reddit.com", "pinterest.com", "tumblr.com", "x.com",
    "microsoft.com", "aws.com"
]

# Function to test TCP connection to a host on port 443
def test_connection(host):
    try:
        # Create a socket object
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)  # Set timeout to 5 seconds
        # Attempt to connect to host on port 443
        result = sock.connect_ex((host, 443))
        # Close the socket
        sock.close()
        # Return result: ComputerName, RemotePort, TcpTestSucceeded
        return {
            "ComputerName": host,
            "RemotePort": 443,
            "TcpTestSucceeded": result == 0  # 0 means success
        }
    except Exception as e:
        return {
            "ComputerName": host,
            "RemotePort": 443,
            "TcpTestSucceeded": False
        }

# Record start time
start_time = time.time()

# Run connection tests in parallel with a max of 12 workers
results = []
with concurrent.futures.ThreadPoolExecutor(max_workers=12) as executor:
    # Map the test_connection function to all URLs
    futures = [executor.submit(test_connection, url) for url in urls]
    # Collect results as they complete
    for future in concurrent.futures.as_completed(futures):
        results.append(future.result())

# Record end time and calculate duration
end_time = time.time()
duration = end_time - start_time

# Write results to file
with open("testWebHostPython.txt", "w") as f:
    # Write header
    f.write(f"{'ComputerName':<20} {'RemotePort':<12} {'TcpTestSucceeded':<15}\n")
    f.write("-" * 50 + "\n")
    # Write each result
    for result in results:
        f.write(f"{result['ComputerName']:<20} {result['RemotePort']:<12} {result['TcpTestSucceeded']:<15}\n")
    # Write duration
    f.write(f"\nExecution Duration: {duration:.2f} seconds\n")