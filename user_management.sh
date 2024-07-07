#!/bin/bash

SCRIPT_PASSWORD="DCIT206"
DEFAULT_PASSWORD="DCIT206"

# Prompt for script execution password
read -sp "Enter script password: " INPUT_PASSWORD
echo

if [[ "$INPUT_PASSWORD" != "$SCRIPT_PASSWORD" ]]; then
    echo "Incorrect password. Exiting."
    exit 1
fi

# Function to add a user
add_user() {
    read -p "Enter username: " USERNAME
    list_groups
    read -p "Enter group name: " GROUPNAME

    # Check if group exists
    if ! getent group "$GROUPNAME" > /dev/null; then
        echo "Group $GROUPNAME does not exist. Please create it first."
        return
    fi

    sudo useradd -m -g "$GROUPNAME" -s /bin/bash "$USERNAME"
    echo "$USERNAME:$DEFAULT_PASSWORD" | sudo chpasswd
    echo "User $USERNAME added with default password."
}

# Function to delete a user
delete_user() {
    read -p "Enter username: " USERNAME

    sudo userdel -r "$USERNAME"
    echo "User $USERNAME deleted."
}

# Function to list users
list_users() {
    cut -d: -f1 /etc/passwd
}

# Function to create a group
create_group() {
    read -p "Enter group name: " GROUPNAME
    sudo groupadd "$GROUPNAME"
    echo "Group $GROUPNAME created."
}

# Function to delete a group
delete_group() {
    read -p "Enter group name: " GROUPNAME
    sudo groupdel "$GROUPNAME"
    echo "Group $GROUPNAME deleted."
}

# Function to list groups
list_groups() {
    cut -d: -f1 /etc/group
}

# Function to modify user
modify_user() {
    read -p "Enter username to modify: " USERNAME
    
    echo "1. Change Username"
    echo "2. Change Password"
    echo "3. Change Group"
    read -p "Choose an option: " MODIFY_OPTION

    case $MODIFY_OPTION in
        1)
            read -p "Enter new username: " NEW_USERNAME
            sudo usermod -l "$NEW_USERNAME" "$USERNAME"
            echo "Username changed from $USERNAME to $NEW_USERNAME."
            USERNAME=$NEW_USERNAME
            ;;
        2)
            sudo passwd "$USERNAME"
            echo "Password for $USERNAME has been changed."
            ;;
        3)
            list_groups
            read -p "Enter new group name: " NEW_GROUPNAME

            # Check if group exists
            if ! getent group "$NEW_GROUPNAME" > /dev/null; then
                echo "Group $NEW_GROUPNAME does not exist. Please create it first."
                return
            fi

            sudo usermod -g "$NEW_GROUPNAME" "$USERNAME"
            echo "User $USERNAME's group changed to $NEW_GROUPNAME."
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
}

# Function to monitor user activity
monitor_user_activity() {
    last
}

# Main menu
while true; do
    echo "User Management Menu"
    echo "1. Add User"
    echo "2. Delete User"
    echo "3. List Users"
    echo "4. Modify User"
    echo "5. Monitor User Activity"
    echo "6. Create Group"
    echo "7. Delete Group"
    echo "8. List Groups"
    echo "9. Exit"
    read -p "Choose an option: " OPTION

    case $OPTION in
        1) add_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) modify_user ;;
        5) monitor_user_activity ;;
        6) create_group ;;
        7) delete_group ;;
        8) list_groups ;;
        9) exit ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
