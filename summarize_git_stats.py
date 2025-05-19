import matplotlib.pyplot as plt
import subprocess
import sys
import re
import os
from collections import defaultdict
from datetime import datetime
import hashlib
import random

# Set the style using Seaborn
plt.style.use("seaborn-v0_8")


def generate_unique_colors(users, alpha=0.7):
    """
    Generate unique RGB color codes for a given list of users.

    Args:
        users (list): List of user names.
        alpha (float): Opacity level of the colors (default: 0.7).

    Returns:
        dict: A dictionary mapping each user to an (R, G, B, alpha) color tuple.

    Example:
        >>> users = ["Alice", "Bob"]
        >>> generate_unique_colors(users)
        {'Alice': (0.5, 0.4, 0.8, 0.7), 'Bob': (0.7, 0.3, 0.2, 0.7)}
    """
    color_mapping = {}
    for user in users:
        # Generate a hash for the user
        hash_object = hashlib.md5(user.encode())
        hex_digest = hash_object.hexdigest()

        # Use the hash to generate a random color
        random.seed(int(hex_digest, 16))  # Seed with the hash value
        color_mapping[user] = (
            1 - random.randint(0, 255) / 255.0,  # Red (normalized)
            1 - random.randint(0, 255) / 255.0,  # Green (normalized)
            1 - random.randint(0, 255) / 255.0,  # Blue (normalized)
            alpha
        )
    return color_mapping


def get_git_user_commit_summary(start_year=2014, end_year=None):
    """
    Generate a summary of git contributions for a specified time range.

    Args:
        start_year (int): The starting year for the analysis.
        end_year (int, optional): The ending year for the analysis. Defaults to the current year.

    Returns:
        dict: A dictionary containing the following keys:
            - 'git_commits': Number of commits per user.
            - 'lines_added': Number of lines added per user.
            - 'lines_deleted': Number of lines deleted per user.
            - '#core_code_lines_current': Current lines of code contributed by each user.

    Example:
        >>> get_git_user_commit_summary(2020, 2023)
        {'git_commits': {'Alice': 10, 'Bob': 5}, 'lines_added': {...}, ...}
    """
    year_now = datetime.now().strftime('%Y')
    if end_year is None:
        end_year = year_now
    
    end_date = f"{end_year}-12-31"
    if end_year == int(year_now):
        end_date = datetime.now().strftime('%Y-%m-%d')

    if end_year == 2021 and start_year != 2021:
        end_date = f"{end_year}-11-24" # start of Sindbad.jl repo

    start_date = f"{start_year}-01-01"
    if start_year == 2021:
        start_date = f"{start_year}-11-25" # start of Sindbad.jl repo

    # Run git log to get commit details along with authors
    log_result = subprocess.run(
        ['git', 'log', '--since=' + start_date, '--until=' + end_date, '--shortstat', '--pretty=format:%an'],
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
    current_author = None

    for line in log_output:
        if not line.startswith(' '):  # Author name line
            current_author = line.strip()
            if current_author:
                commit_summary['git_commits'][current_author] = commit_summary['git_commits'].get(current_author, 0) + 1
        else:  # Statistics line (lines added/deleted)
            added = re.search(r'(\d+) insertions', line)
            deleted = re.search(r'(\d+) deletions', line)
            if added:
                commit_summary['lines_added'][current_author] = commit_summary['lines_added'].get(current_author, 0) + int(added.group(1))
            if deleted:
                commit_summary['lines_deleted'][current_author] = commit_summary['lines_deleted'].get(current_author, 0) + int(deleted.group(1))

    # Add current lines of code contributed by each user
    print(start_year, start_date, end_year, end_date)
    commit_summary['#core_code_lines_current'] = get_code_lines_contributed(date_to_check=end_date)

    return commit_summary


def get_code_lines_contributed(date_to_check=None):
    """
    Calculate the lines of code contributed by each user in the main directories of a repository 
    using `git blame`. The function determines the repository structure based on a specific date 
    and optionally switches to a commit closest to that date before performing the analysis.

    Args:
        date_to_check (str, optional): A date in the format 'YYYY-MM-DD' to analyze code contributions 
            as of that date. If None, the current date is used.

    Returns:
        dict: A dictionary containing:
            - "version" (str): The code version (MATLAB or Julia) and the date analyzed.
            - "code" (dict): A mapping of each user to the number of lines they contributed.

    Raises:
        RuntimeError: If there are uncommitted changes in the repository that could risk unsaved work.

    Example:
        >>> get_code_lines_contributed("2023-02-15")
        {'version': 'Julia@2023-02-15', 'code': {'Alice': 120, 'Bob': 80}}
    
    Notes:
        - If there are uncommitted changes, the function will raise an error and terminate execution.
        - For dates prior to "2021-11-25", the function assumes a MATLAB repository structure.
        - After "2021-11-25", the function assumes a Julia repository structure.
        - The function uses `git blame` to calculate contributions and processes files 
          with extensions `.jl` and `.m`.
        - If the function switches to a specific commit, it restores the working directory 
          to the latest commit at the end.
    """
    # Specify the date and time
    year_now = datetime.now().strftime('%Y')
    if date_to_check is None:
        date_to_check = datetime.now().strftime('%Y-%m-%d')

    check_out = True
    if date_to_check.split('-')[0] == year_now:
        check_out = False

    if check_out == True:
        try:
            status_result = subprocess.run(
                ["git", "status", "--porcelain"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=True
            )
            has_uncommitted_changes = bool(status_result.stdout.strip())
            if has_uncommitted_changes:
                raise RuntimeError("Uncommitted changes detected when the selected end_date requires a checkout to old commit. Due to risk of losing unsaved work, commit or stash your current changes before doing the git stats.")
            # Step 2: Stash uncommitted changes if they exist
            if has_uncommitted_changes:
                print("Uncommitted changes detected. Stashing changes...")
                    # Step 1: Find the commit hash before the specified time
            result = subprocess.run(
                ["git", "rev-list", f"--before={date_to_check}", "--max-count=1", "HEAD"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=True
            )
            commit_hash = result.stdout.strip()

            if commit_hash:
                print(f"Commit found: {commit_hash}")

                # Step 2: Checkout the commit
                subprocess.run(
                    ["git", "checkout", commit_hash],
                    check=True
                )
                print(f"Checked out commit: {commit_hash}")
            else:
                print("No commit found before the specified date.")

        except subprocess.CalledProcessError as e:
            print(f"Error: {e.stderr}")
        
    user_line_counts = defaultdict(int)


    # Example date strings
    date_julia_begin = "2021-11-25"

    # Convert strings to datetime objects
    format = "%Y-%m-%d"  # Define the format of the date strings
    datetime_julia_begin = datetime.strptime(date_julia_begin, format)
    datetime_to_check = datetime.strptime(date_to_check, format)

    # Compare the dates
    if datetime_to_check < datetime_julia_begin:
        code_version = "MATLAB"
        dirs_to_walk = ("documentation", "tools", "model", "optimization")
    else:
        code_version = "Julia"
        dirs_to_walk = ("src/", "lib/", "docs/")
    print(f"checking: {dirs_to_walk} on {date_to_check}")
    # Walk through the repository and find all files
    for directory in dirs_to_walk:
        for root, _, files in os.walk(directory):
            for file in files:
                # Process only relevant file extensions
                if file.endswith(('.jl', '.m', )):
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
    if check_out == True:
        subprocess.run(
            ["git", "checkout", "-"],  # The '-' option switches back to the previous branch
            check=True
        )
    return {"version":f"{code_version}@{date_to_check}", "code":dict(user_line_counts)}


if __name__ == "__main__":
    """
    Main script to generate contribution summaries and create pie charts for visualization.

    This script analyzes git contributions (commits, lines added, lines deleted, and current lines of code)
    for a specified time range and generates pie charts to visualize the contributions.

    Usage:
        python summarize_git_stats.py <start_year> [<end_year>]

    Args:
        <start_year> (int): The starting year for the analysis.
        <end_year> (int, optional): The ending year for the analysis. Defaults to the current year.

    Example:
        1. Analyze contributions from 2014 to now (all-developments):
            $ python summarize_git_stats.py 2014

        2. Analyze contributions from 2020 to 2023:
            $ python summarize_git_stats.py 2020 2023

        3. Analyze contributions from 2020 to now = SINDBAD.jl:
            $ python summarize_git_stats.py 2020

        4. Analyze contributions from 2014 to 2020 = SINDBAD in MATLAB:
            $ python summarize_git_stats.py 2014 2020
    Output:
        - Contribution summaries are printed to the console.
        - Pie charts are saved in the `tmp_git_summary/` directory with filenames like:
            - `summary_git_commits_<start_year>-<end_year>.png`
            - `summary_lines_added_<start_year>-<end_year>.png`
            - `summary_lines_deleted_<start_year>-<end_year>.png`
            - `summary_core_code_lines_current_<start_year>-<end_year>.png`
    """    # Parse command-line arguments for start and end years
    start_year = 2014
    year_now = int(datetime.now().strftime('%Y'))
    date_today = datetime.now().strftime('%Y-%m-%d')
    end_year = year_now
    # year_sets = [[start_year, end_year]]
    print(len(sys.argv), sys.argv)
    if len(sys.argv) == 1:
        year_sets =[[2014, 2021], [2014, 2025], [2017, 2021], [2021, 2022], [2022, 2023], [2023, 2024], [2024, 2025], [2021, 2025]]

    else:
        if len(sys.argv) > 1:
            start_year = int(sys.argv[1])
            if len(sys.argv) > 2:
                end_year = int(sys.argv[2])
        year_sets = [[start_year, end_year]]
    # Get contribution summary
    for year_set in year_sets:
        (start_year, end_year) = year_set
        print(f"Analyzing contributions from {start_year} to {end_year}...")
        # Get contribution summary
        contribution_summary = get_git_user_commit_summary(start_year=start_year, end_year=end_year)

        # Define user aliases to merge contributions
        user_aliases = {
            "dr-ko": ["skoirala"],
            "Nuno": ["Nuno Carvalhais", "NC", "ncarval"],
            "Lazaro Alonso": ["Lazaro Alonso Silva", "lazarusA", "Lazaro", "lalonso"],
            "Fabian Gans": ["meggart"],
            "Tina Trautmann": ["Tina"]
        }
        alias_values = [alias for aliases in user_aliases.values() for alias in aliases]

        all_users = contribution_summary["git_commits"].keys()
        user_colors = generate_unique_colors(all_users, alpha=0.9)

        # Analyze and visualize contributions for each metric
        for metric in ("git_commits", "lines_added", "lines_deleted", "#core_code_lines_current"):
            metric_data = contribution_summary[metric]
            if metric == "#core_code_lines_current":
                code_version = metric_data["version"]
                metric_data = metric_data["code"]
            unique_user_data = {}

            # Merge contributions for users with aliases
            for user in metric_data.keys():
                if user not in alias_values:
                    total_contribution = metric_data[user]
                    if user in user_aliases:
                        for alias in user_aliases[user]:
                            if alias in metric_data:
                                total_contribution += metric_data[alias]
                    unique_user_data[user] = total_contribution

            # Sort users alphabetically
            sorted_users = sorted(unique_user_data.keys())
            custom_labels = [f'{label}' for label in sorted_users]
            sorted_colors = [user_colors[user] if (user in user_colors.keys()) else "#cccccc" for user in sorted_users]

            # Print contribution summary
            for user, count in unique_user_data.items():
                print(f"{user}: {count} {metric.lower()}")

            # Prepare data for pie chart
            contributions = [unique_user_data[user] for user in sorted_users]
            explode_slices = [0.1 for _ in contributions]  # Explode all slices for better visibility

            # Create pie chart
            plt.figure(figsize=(10, 8))
            bbox_props = dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor="lightgray", alpha=0.1)
            custom_labels = [f'{label}' for label in sorted_users]
            bbox_props_text = dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor="white", alpha=1.0)
            # Create pie chart
            fig, ax = plt.subplots()
            wedges, texts, autotexts = ax.pie(contributions, explode=explode_slices, colors=sorted_colors, labels=custom_labels, autopct='%1.1f%%', startangle=140)

            # Make labels bold and add bbox background
            for i, text in enumerate(texts):
                text.set_fontweight('bold')
                # text.set_color(sorted_colors[i])
                bbox_props = dict(boxstyle="round,pad=0.3", edgecolor="black", facecolor=sorted_colors[i], alpha=0.2)
                text.set_bbox(bbox_props)
            # Style the percentage texts
            for autotext in autotexts:
                autotext.set_fontweight('bold')
                autotext.set_bbox(bbox_props_text)
            ax.set_aspect('equal')  # Ensure the pie chart is circular
            title_plot = (f"{metric} (total: {sum(contributions)})\n{start_year}-{end_year}\nas of {date_today}")
            if metric == "#core_code_lines_current":
                title_plot = (f"{metric} (total: {sum(contributions)})\nversion: {code_version}\nas of {date_today}")
                

            plt.title(title_plot)
            os.makedirs('tmp_git_summary/', exist_ok=True)
            plt.savefig(f"tmp_git_summary/summary_{metric.lower()}_{start_year}-{end_year}.png", dpi=300)
            print("----------------------")

