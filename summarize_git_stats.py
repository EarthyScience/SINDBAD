import matplotlib.pyplot as plt
import subprocess
import sys
import re
import os
from collections import defaultdict
from datetime import datetime, timedelta

# Set the style using Seaborn
plt.style.use("seaborn-v0_8")

def get_git_user_commit_summary(start_year=2014):
    """
    Generate a summary of git contributions for the past `n` years.

    Args:
        n (int): Number of years to look back for git contributions.

    Returns:
        dict: A dictionary containing the following keys:
            - 'git_commits': Number of commits per user.
            - 'lines_added': Number of lines added per user.
            - 'lines_deleted': Number of lines deleted per user.
            - '#code_lines_current': Current lines of code contributed by each user.
    """
    # n_years_ago = (datetime.now() - timedelta(days=n * 365)).strftime('%Y-%m-%d')
    start_date = f"{start_year}-01-01"
    # Run git log to get commit details along with authors
    log_result = subprocess.run(
        ['git', 'log', '--since=' + start_date, '--shortstat', '--pretty=format:%an'],
        capture_output=True, text=True
    )
    if log_result.returncode != 0:
        raise Exception("Error running git log command.")
    
    # Parse the output
    log_output = log_result.stdout.strip().split('\n')
    
    commit_summary = {
        'git_commits': {},
        'lines_added': {},
        'lines_deleted': {}
    }
    current_user = None

    for line in log_output:
        if not line.startswith(' '):  # User name line
            current_user = line.strip()
            if current_user:
                commit_summary['git_commits'][current_user] = commit_summary['git_commits'].get(current_user, 0) + 1
        else:  # Statistics line (lines added/deleted)
            added = re.search(r'(\d+) insertions', line)
            deleted = re.search(r'(\d+) deletions', line)
            if added:
                commit_summary['lines_added'][current_user] = commit_summary['lines_added'].get(current_user, 0) + int(added.group(1))
            if deleted:
                commit_summary['lines_deleted'][current_user] = commit_summary['lines_deleted'].get(current_user, 0) + int(deleted.group(1))

    # Add current lines of code contributed by each user
    commit_summary['#code_lines_current'] = get_current_lines_contributed_by_user()
    
    return commit_summary

def get_current_lines_contributed_by_user():
    """
    Calculate the current lines of code contributed by each user using `git blame`.

    Returns:
        dict: A dictionary mapping each user to the number of lines they contributed.
    """
    user_line_counts = defaultdict(int)  # Dictionary to store line counts per user
    
    # Walk through the repository and find all files
    for root, _, files in os.walk('.'):
        for file in files:
            # Process only relevant file extensions
            if file.endswith(('.jl', '.json', '.m', '.md')):  # Add relevant extensions
                file_path = os.path.join(root, file)
                
                try:
                    # Run git blame on the file
                    result = subprocess.run(
                        ['git', 'blame', '--line-porcelain', file_path],
                        capture_output=True, text=True
                    )
                    if result.returncode != 0:
                        continue
                    
                    # Parse the blame output to extract authors
                    blame_output = result.stdout.strip().split('\n')
                    for line in blame_output:
                        if line.startswith('author '):  # Extract author name
                            author = line.split('author ')[1].strip()
                            user_line_counts[author] += 1
                    
                except Exception as e:
                    print(f"Error processing file {file_path}: {e}")
    
    return dict(user_line_counts)

if __name__ == "__main__":
    """
    Main script to generate contribution summaries and create pie charts for visualization.
    """
    # Number of years to analyze (default is 1 year)
    start_year = 2014
    if len(sys.argv) > 1:
        start_year = int(sys.argv[1])
    
    # Get contribution summary
    contrib_summary = get_git_user_commit_summary(start_year=start_year)
    
    # Define user aliases to merge contributions
    users_repeat = {
        "dr-ko": ["skoirala"],
        "Nuno": ["Nuno Carvalhais", "NC", "ncarval"],
        "Lazaro Alonso": ["Lazaro Alonso Silva", "lazarusA", "Lazaro", "lalonso"],
        "Fabian Gans": ["meggart"],
        "Tina Trautmann": ["Tina"]
    }
    users_repeat_values = [item for sublist in users_repeat.values() for item in sublist]
    
    # Analyze and visualize contributions for each metric
    for ss in ("git_commits", "lines_added", "lines_deleted", "#code_lines_current"):
        ss_data = contrib_summary[ss]
        all_users = ss_data.keys()

        # Merge contributions for users with aliases
        ss_data_uniq = {}
        for au in all_users:
            if au not in users_repeat_values:
                contrib = ss_data[au]
                if au in users_repeat.keys():
                    for ru in users_repeat[au]:
                        if ru in all_users:
                            contrib += ss_data[ru]
                ss_data_uniq[au] = contrib

        # Sort users alphabetically
        uniq_users = sorted(ss_data_uniq.keys())
        
        # Print contribution summary
        for user, count in ss_data_uniq.items():
            print(f"{user}: {count} {ss.lower()}")

        # Prepare data for pie chart
        contribs = [ss_data_uniq[_us] for _us in uniq_users]
        explode = [0.1 for _ in contribs]  # Explode all slices for better visibility
        
        # Create pie chart
        plt.figure(figsize=(10, 8))
        plt.pie(contribs, explode=explode, labels=uniq_users, autopct='%1.1f%%', startangle=140)
        plt.title(f"{ss} (total: {sum(contribs)}) since {start_year}")
        os.makedirs('tmp_git_summary/', exist_ok=True)
        plt.savefig(f"tmp_git_summary/summary_{ss.lower()}_since-{start_year}.png", dpi=300)
        print("----------------------")