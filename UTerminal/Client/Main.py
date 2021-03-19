import sys      # Input
import re       # Regex
import socket   # Tcp connection

BUFFER_SIZE = 1024

re_userhost = "^[A-Za-z][A-Za-z0-9_]*\@[A-Za-z0-9][A-Za-z0-9_\.]*"

# Validate arguments
argc = len(sys.argv)
if argc == 1 or not re.compile(re_userhost).match(sys.argv[1]):
    print("Usage: uterminal <username>@<servername>")
    quit()

# Extract user and host names
index_at = sys.argv[1].index("@")
username = sys.argv[1][:index_at]
hostname = ""
port = 0

if ":" in sys.argv[1]:
    index_colon = sys.argv[1].index(":")
    hostname = sys.argv[1][index_at + 1:index_colon]
    port = int(sys.argv[1][index_colon + 1:])
else:
    hostname = sys.argv[1][index_at + 1:]
    port = 80 # Default port

# Connect to host
connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
connection.connect((hostname, port))

# Send username, await prompt
auth_string = "AUTH " + username
connection.send(auth_string.encode('UTF-8'))
data = connection.recv(BUFFER_SIZE)
print(f"{data.decode('UTF-8')}", end='', flush=True)

# Authentication
user_input = input()
auth_string = "AUTH " + user_input
connection.send(auth_string.encode('UTF-8'))
data = connection.recv(BUFFER_SIZE)
print(f"{data.decode('UTF-8')}")

while True:
    print("> ", end='', flush=True)
    user_input = input()
    if user_input == "quit" or user_input == "exit":
        break
    cmd_string = "CMD " + user_input
    connection.send(cmd_string.encode('UTF-8'))
    data = connection.recv(BUFFER_SIZE)
    print(f"{data.decode('UTF-8')}")

connection.close()