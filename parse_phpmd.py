#!/usr/bin/env python3
import json
import sys
import requests
max_number_per_request = 50 # this is the max number of anotation per requset

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
    violations = [] # for max_number_per_request annotations  
    all_violations = [] # array of violations
    # Opening JSON file and load
    with open(json_file, 'r') as j:
     contents = json.loads(j.read())

    github_prefix = "/github/workspace/"
    for file in contents["files"]:
    # adding violations items to list
        for violation in file["violations"]:
            violation_item = {"path": file["file"].replace(github_prefix,""), "start_line": violation["beginLine"],
         "end_line": violation["endLine"], "annotation_level": "warning", "message": violation["description"]}
            if len(violations) < max_number_per_request:
                violations.append(violation_item)
            else:
                all_violations.append(violations)
                violations = []
        all_violations.append(violations)
    return all_violations

def update_pr(owner, repo_name, head_sha, file):
    URL = "https://pm-code-check.pm-projects.de/pm-checks/annotations/create"
    params = {"owner": owner, "repo_name": repo_name, "head_sha": head_sha, "check_name": "Phpmd check"}
    head = {"Content-Type'": "application/json"}
    all_violations = get_all_violations(file)
    for violations in all_violations:
        response = requests.post(URL, json=violations, params=params, headers=head)



def main():
    owner = sys.argv[1]
    repo_name = sys.argv[2]
    head_sha = sys.argv[3]
    file = sys.argv[4]
    update_pr(owner, repo_name, head_sha, file)

main()
