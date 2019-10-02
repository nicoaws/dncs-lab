#! /usr/bin/env python3

import random
import re

TEMPLATE_FILE = 'answers-template.yml'
README_FILE = 'README.md'
OUTPUT_FILE = 'answers.yml'
REPLACEMENT_DICT = { 
    'FirstName': 'first_name',
    'LastName':  'last_name',
    'MatriculationNumber': 'mat_number',
    'HostsASubnetRequiredAddresses': 'host_a_subnet_addresses', 
    'HostsBSubnetRequiredAddresses': 'host_b_subnet_addresses', 
    'HubSubnetRequiredAddresses': 'hub_subnet_addresses'
}

first_name=str(input('Enter your First Name: '))
last_name=str(input('Enter your Last Name: '))
mat_number=str(input('Enter your Matriculation Nr.: '))

random.seed(a=first_name+last_name+mat_number,
            version=2)

host_a_subnet_addresses = str(random.randint(24, 520))
host_b_subnet_addresses = str(random.randint(24, 520))
hub_subnet_addresses = str(random.randint(24, 520))

# Read template file
with open(TEMPLATE_FILE,'r') as template_file:
    with open(OUTPUT_FILE,'w') as output_file:
        for line in template_file.readlines():
            for replacement_string, replacement_value in REPLACEMENT_DICT.items():
                regex = r'\{\{ %s \}\}' % replacement_string
                line=re.sub(regex,eval(replacement_value),line)
            output_file.write(line)

# Modify README.md file
with open(README_FILE,'r') as readme_file:
    readme_file_lines = readme_file.readlines()

with open(README_FILE,'w') as readme_file:
    for line in readme_file_lines:
        for replacement_string, replacement_value in REPLACEMENT_DICT.items():
            regex = r'\{\{ %s \}\}' % replacement_string
            line=re.sub(regex,eval(replacement_value),line)
        readme_file.write(line)