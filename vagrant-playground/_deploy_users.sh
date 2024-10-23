#!/usr/bin/env bash

set -euo pipefail

create_user_with_ssh_and_sudo() {
    local username="$1"
    local ssh_key="$2"
    local sudoers_file="/etc/sudoers.d/$username"

    id "$username" &>/dev/null || useradd -m -s /bin/bash "$username"
    passwd -l "$username" >> /dev/null

    mkdir -p /home/"$username"/.ssh/
    touch /home/"$username"/.ssh/authorized_keys

    echo "$ssh_key" > /home/"$username"/.ssh/authorized_keys
    chown -R "$username":"$username" /home/"$username"/.ssh/
    chmod 700 /home/"$username"/.ssh/
    chmod 600 /home/"$username"/.ssh/authorized_keys

    cat <<EOF > "$sudoers_file"
$username ALL=(ALL) NOPASSWD:ALL
EOF
    chmod 440 "$sudoers_file"
}

create_user_with_ssh_and_sudo "stephane-klein" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEzyNFlEuHIlewK0B8B0uAc9Q3JKjzi7myUMhvtB3JmA2BqHfVHyGimuAajSkaemjvIlWZ3IFddf0UibjOfmQH57/faxcNEino+6uPRjs0pFH8sNKWAaPX1qYqOFhB3m+om0hZDeQCyZ1x1R6m+B0VJHWQ3pxFaxQvL/K+454AmIWB0b87MMHHX0UzUja5D6sHYscHo57rzJI1fc66+AFz4fcRd/z+sUsDlLSIOWfVNuzXuGpKYuG+VW9moiMTUo8gTE9Nam6V2uFwv2w3NaOs/2KL+PpbY662v+iIB2Yyl4EP1JgczShOoZkLatnw823nD1muC8tYODxVq7Xf7pM/NSCf3GPCXtxoOEqxprLapIet0uBSB4oNZhC9h7K/1MEaBGbU+E2J5/5hURYDmYXy6KZWqrK/OEf4raGqx1bsaWcONOfIVXbj3zXTUobsqSkyCkkR3hJbf39JZ8/6ONAJS/3O+wFZknFJYmaRPuaWiLZxRj5/gw01vkNVMrogOIkQtzNDB6fh2q27ghSRkAkM8EVqkW21WkpB7y16Vzva4KSZgQcFcyxUTqG414fP+/V38aCopGpqB6XjnvyRorPHXjm2ViVWbjxmBSQ9aK0+2MeKA9WmHN0QoBMVRPrN6NBa3z20z1kMQ/qlRXiDFOEkuW4C1n2KTVNd6IOGE8AufQ== contact@stephane-klein.info"

create_user_with_ssh_and_sudo "john-doe" "..."
