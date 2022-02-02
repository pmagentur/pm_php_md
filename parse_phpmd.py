#!/usr/bin/env python3
import json
import sys
import requests

# Annotation should have this structure
# Annotation = {                
#   path: string;
#   start_line: number;
#   end_line: number;
#   start_column?: number; #optional
#   end_column?: number; #optional
#   annotation_level: "notice" | "warning" | "failure";
#   message: string;
#   title?: string; #optional
#   raw_details?: string; #optional
# }


def get_all_violations(json_file: str) -> dict:
    violations = []  
    # Opening JSON file and load
    with open(json_file, 'r') as j:
     contents = json.loads(j.read())

    github_prefix = "/github/workspace/"
    for file in contents["files"]:
    # adding violations items to list
        for violation in file["violations"]:
            violation_item = {"path": file["file"].replace(github_prefix,""), "start_line": violation["beginLine"],
         "end_line": violation["beginLine"], "annotation_level": "warning", "message": violation["description"]}
            violations.append(violation_item)
    return violations

def update_pr(owner, repo_name, head_sha, file):
    URL = "https://pm-code-check.pm-projects.de/pm-checks/annotations/create"
    params = {"owner": owner, "repo_name": repo_name, "head_sha": head_sha, "check_name": "Phpmd check"}
    head = {"Content-Type'": "application/json"}
    all_violations = get_all_violations(file)
    print(all_violations)
    response = requests.post(URL, json=all_violations, params=params, headers=head)
    print(response)



def main():
    owner = sys.argv[1]
    repo_name = sys.argv[2]
    head_sha = sys.argv[3]
    file = sys.argv[4]
    update_pr(owner, repo_name, head_sha, file)

main()
