Attendance Tracker Setup Script
A bash script that automates the creation of a student attendance tracker project. Instead of setting up folders and files manually, the script does everything in a few seconds.
What it does
Creates the full project directory structure automatically
Copies all source files into the correct locations
Lets you configure attendance thresholds through the terminal
Uses sed to update config.json without overwriting the whole file
Catches Ctrl+C interrupts and saves your work into an archive before exiting
Checks if Python3 is installed and verifies all files are in the right place

