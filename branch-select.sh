#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null
then
    echo "git could not be found. Please install git to use this script."
    exit 1
fi

# Check if fzf is installed
if ! command -v fzf &> /dev/null
then
    echo "fzf could not be found. Please install fzf to use this script."
    exit 1
fi

# ANSI color codes
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Get the list of recent branches and filter out duplicates
recent_branches=$(git reflog | grep -i 'checkout:' | awk '{print $1 " " $2 " " $NF}' | awk '!seen[$3]++' | head -n 10)

# Reformat the output to "branch_name commit_hash reflog_entry" with colors
formatted_branches=$(echo "$recent_branches" | awk -v blue="$BLUE" -v nc="$NC" '{print blue $3 nc " " $1 " " $2}')

# Convert the branches to an array
IFS=$'\n' read -r -d '' -a branches <<< "$formatted_branches"

# Display the menu
PS3="Enter a number: "
echo "Select a branch to checkout:"
select branch in "${branches[@]}"; do
    if [[ -n "$branch" ]]; then
        # Extract the branch name
        branch_name=$(echo "$branch" | awk '{print $1}' | perl -pe 's/\x1b\[[0-9;]*m//g')
        echo -e "Checking out branch: $branch_name"
        git checkout "$branch_name"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done
