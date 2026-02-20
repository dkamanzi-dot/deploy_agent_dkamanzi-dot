#!/bin/bash

# ask user for a project name to use in the folder
echo "Enter a project identifier (e.g., v1):"
read input
project_name="attendance_tracker_${input}"

# runs if user presses Ctrl+C, saves work and cleans up
cleanup() {
    echo ""
    echo "Script interrupted. Saving current state..."
    tar -czf "${project_name}_archive.tar.gz" "$project_name" 2>/dev/null
    rm -rf "$project_name"
    echo "Archive saved as: ${project_name}_archive.tar.gz"
    echo "Removed incomplete directory."
    exit 1
}
trap cleanup SIGINT

# create the main folder structure
echo "Setting up project directories..."
mkdir -p "$project_name/Helpers"
mkdir -p "$project_name/reports"

# copy source files in, or create empty ones if not found
if [[ -f "attendance_checker.py" ]]; then
    cp attendance_checker.py "$project_name/attendance_checker.py"
else
    touch "$project_name/attendance_checker.py"
fi

if [[ -f "assets.csv" ]]; then
    cp assets.csv "$project_name/Helpers/assets.csv"
else
    touch "$project_name/Helpers/assets.csv"
fi

if [[ -f "config.json" ]]; then
    cp config.json "$project_name/Helpers/config.json"
else
    echo '{ "warning": 75, "failure": 50 }' > "$project_name/Helpers/config.json"
fi

if [[ -f "reports.log" ]]; then
    cp reports.log "$project_name/reports/reports.log"
else
    touch "$project_name/reports/reports.log"
fi

# ask if user wants to change the attendance thresholds
echo "Would you like to update attendance thresholds? (y/n)"
read update_choice

if [[ "$update_choice" == "y" || "$update_choice" == "Y" ]]; then
    echo "Enter Warning threshold (default 75):"
    read warning
    echo "Enter Failure threshold (default 50):"
    read failure

    # make sure both values are numbers
    if ! [[ "$warning" =~ ^[0-9]+$ && "$failure" =~ ^[0-9]+$ ]]; then
        echo "Thresholds must be numbers. Keeping current values."
    # make sure failure is lower than warning
    elif [[ "$failure" -ge "$warning" ]]; then
        echo "Failure threshold must be lower than warning. Keeping current values."
    else
        # use sed to update the values inside config.json
        sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$project_name/Helpers/config.json"
        sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$project_name/Helpers/config.json"
        echo "Thresholds updated: Warning=${warning}%, Failure=${failure}%"
    fi
else
    echo "Keeping default thresholds."
fi

# print what config.json looks like now
echo ""
echo "config.json now contains:"
cat "$project_name/Helpers/config.json"

# check if python3 is installed on the machine
echo ""
echo "Checking environment..."
if command -v python3 &>/dev/null; then
    python3 --version
    echo "Python3 found."
else
    echo "Warning: Python3 is not installed."
fi

# confirm all expected files exist in the right places
echo ""
echo "Checking project files..."
for path in \
    "$project_name/attendance_checker.py" \
    "$project_name/Helpers/assets.csv" \
    "$project_name/Helpers/config.json" \
    "$project_name/reports/reports.log"
do
    if [[ -e "$path" ]]; then
        echo "  OK: $path"
    else
        echo "  MISSING: $path"
    fi
done

echo ""
echo "Done. Project created at: $project_name"
