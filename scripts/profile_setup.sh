#!/bin/bash

sample_profile=$(cat ./docs/sample_profiles.yml)

printf "Creating .dbt folder in the home directory to house the profile...\n"
mkdir ~/.dbt

printf "\nCopying the project sample template profile to profiles.yml in the .dbt directory...\n"
echo "$sample_profile" >> ~/.dbt/profiles_test.yml

printf "\nAttempting to open the generated profile in VS Code...\n"
code ~/.dbt/profiles_test.yml

printf "\nDone! Now, please fill out the profiles.yml file as directed in the in-line comments."
