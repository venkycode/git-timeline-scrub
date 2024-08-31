#!/bin/bash

# Function to find the commit on main branch
find_commit_on_main() {
    local current_commit=$(git rev-parse --short HEAD)
    if git merge-base --is-ancestor $current_commit main; then
        echo "Current commit is in main branch's history."
        return 0
    else
        echo "Error: Current commit is not in main branch's history."
        exit 1
    fi
}

# Function to remove all staged changes and uncommitted changes
reset_changes() {
    git reset --hard HEAD
    git clean -fd
}

# Function to get the list of commits in main's history
get_main_commits() {
    git rev-list --first-parent --abbrev-commit main
}

find_next_commit(){
    #first argument is the current commit
    current_commit=$1

    main_commits=$(get_main_commits)

    #main commits are listed from latest to oldest

    next_commit=""

    for commit in $main_commits; do
        if [[ "$commit" == "$current_commit" ]]; then
            break
        fi
        next_commit=$commit
    done

    echo $next_commit
}

# Function to move to the next commit
move_to_next_commit() {
    current_commit=$(git rev-parse --short HEAD)
    next_commit=$(find_next_commit $current_commit)
    echo "moving to next commit $next_commit"
    
    if [[ -z "$next_commit" ]]; then
        echo "Already at the latest commit on main branch."
        return 1
    fi
    
    git checkout $next_commit
    return 0
}

# Function to stage changes from the next commit
stage_next_commit_changes() {
    current_commit=$(git rev-parse --short HEAD)
   
    
    # fine next commit by iterating over main commits
    
    next_commit=$(find_next_commit $current_commit)

    echo "next commit is $next_commit"

    
    if [[ -z "$next_commit" ]]; then
        echo "No next commit available on main branch."
        return 1
    fi

    
    git checkout $next_commit
    git reset --soft HEAD^

    return 0
}

# Function to move to the previous commit
move_to_previous_commit() {
    current_commit=$(git rev-parse HEAD)
   
     # find parent of current commit
    parent_commit=$(git rev-parse HEAD^)
    
    git checkout $parent_commit
    return 0
}

# Main script logic
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <next|previous>"
    exit 1
fi

find_commit_on_main
reset_changes

case "$1" in
    "next")
        if move_to_next_commit; then
            stage_next_commit_changes
        fi
        ;;
    "previous")
        move_to_previous_commit
        ;;
    *)
        echo "Invalid argument. Use 'next' or 'previous'."
        exit 1
        ;;
esac