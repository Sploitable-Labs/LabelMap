import os
import json
import csv

folder_path ="rules"
output_file = "output.csv"

def process_data(data, writer):
    # If data only contains one rule then create
    # a list with one entry.
    # If data contains multiple rules then will
    # already be in a JSON list.
    # This just allows us to treat all files the
    # same way after this point.
    if isinstance(data, dict):
        data = [data]
    
    for i in data:
        rule = i['DisplayName']
        policy = i['ParentPolicyName'] # The name of the policy this rule is assocaited with.
        status = "Disabled" if i['Disabled'] else "Enabled" # Is the policy enabled or not.

        # Now for circles of JSON parsing hell... ;)
        if i.get('ContentContainsSensitiveInformation'):
            for j in i['ContentContainsSensitiveInformation']:
                if j and 'groups' in j:
                    for k in j['groups']:
                        if 'labels' in k:
                            for l in k['labels']:
                                label = l['name']
                                writer.writerow([label, status, policy, rule])

with open(output_file, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['label', 'status', 'policy', 'rule']) # Write the header.

    for filename in os.listdir(folder_path):
        if filename.endswith('.json'):
            file_path = os.path.join(folder_path, filename)

            with open(file_path, 'r', encoding='utf-8-sig') as json_file:
                data = json.load(json_file)
                process_data(data, writer)