# /// script
# dependencies = [
#   "requests",
#   "markdown",
#   "PyGithub",
# ]
# ///

import os
import subprocess
from typing import Optional, Dict, List
from github import Github, BadCredentialsException, GithubException

plugins_dir = os.path.expanduser("~/.local/share/nvim/lazy")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
github_client = Github(GITHUB_TOKEN) if GITHUB_TOKEN else Github()


def get_github_url(plugin_path: str) -> Optional[str]:
    """Fetch the GitHub URL of the plugin from its git configuration."""
    try:
        result = subprocess.run(
            ["git", "config", "--get", "remote.origin.url"],
            cwd=plugin_path,
            capture_output=True,
            text=True,
            check=True,
        )
        url = result.stdout.strip()
        return url.replace(".git", "")
    except subprocess.CalledProcessError:
        print(f"Error fetching GitHub URL for {plugin_path}")
        return None


def get_github_description(github_url: str) -> str:
    """Fetch the description of the GitHub repository."""
    repo_name = github_url.split("github.com/")[-1]
    try:
        repo = github_client.get_repo(repo_name)
        return repo.description if repo.description else "No description available."
    except BadCredentialsException:
        print("Invalid GitHub token. Please check your credentials.")
        return "No description available."
    except GithubException as e:
        print(f"Error fetching description for {repo_name}: {e}")
        return "No description available."


def extract_plugin_info(plugin_path: str) -> Optional[Dict[str, str]]:
    """Extract plugin information including name, description, and URL."""
    plugin_name = os.path.basename(plugin_path)
    github_url = get_github_url(plugin_path)
    if github_url is None:
        return None
    description = get_github_description(github_url)
    return {
        "name": plugin_name,
        "description": description,
        "url": github_url,
    }


def create_markdown_table(plugins: List[Dict[str, str]]) -> str:
    """Create a markdown table from the list of plugins."""
    header = "| Plugin Name | Description | GitHub URL |\n"
    separator = "|-------------|-------------|------------|\n"
    rows = ""
    for plugin in plugins:
        if plugin:
            rows += f"| {plugin['name']} | {plugin['description']} | [Link]({plugin['url']}) |\n"
    return header + separator + rows


def generate_markdown_docs() -> None:
    """Generate markdown documentation for Neovim plugins."""
    plugins = []
    for plugin in os.listdir(plugins_dir):
        plugin_path = os.path.join(plugins_dir, plugin)
        if os.path.isdir(plugin_path):
            plugin_info = extract_plugin_info(plugin_path)
            if plugin_info:  # Only add valid plugin info
                plugins.append(plugin_info)
    markdown_table = create_markdown_table(plugins)
    docs_file_path = os.path.expanduser("docs/nvim-plugin-catalog.md")
    with open(docs_file_path, "w", encoding="utf-8") as f:
        f.write("# Neovim Plugins Catalog\n\n")
        f.write(markdown_table)
    print(f"Markdown documentation generated at: {docs_file_path}")


if __name__ == "__main__":
    generate_markdown_docs()
