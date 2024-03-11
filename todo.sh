#!/bin/bash

# Created on 2024/03/11 1:27am
# @author: spanishkukli
# @summary: terminal-based task manager tool

TODO_DIR="./.todo"
CONFIG_FILE="$TODO_DIR/config"

function show_help {
    echo "Uso: todo.sh [-a|-r|-e|-f|-d|-b|-l|-w|-h] [tarea|número de línea|nombre de archivo]"
    echo "  -a    Añadir tarea"
    echo "  -r    Eliminar tarea utilizando el número de línea"
    echo "  -e    Editar tarea por número de línea"
    echo "  -f    Cambiar el archivo de tareas"
    echo "  -d    Poner una tarea como '[done]'"
    echo "  -b    Poner una tarea con el valor predefinido '[ ]'"
    echo "  -l    Listar todas las tareas"
    echo "  -w    Listar todos los ficheros todo"
    echo "  -h    Mostrar ayuda"
    exit 1
}

# Add new task to tasks file
function add_task {
    echo "- [ ] $*" >> "$TODO_FILE"
}

# Remove a task
function remove_task {
    TASK=$(sed "${1}q;d" "$TODO_FILE")
    
    echo "Quieres eliminar la tarea $TASK? [Y/n]"
    read -r OPT

    if [ "$OPT" == "N" ] || [ "$OPT" == "n" ]; then
        :
    else 
        sed -i "${1}d" "$TODO_FILE"
        echo "Tarea eliminada: $TASK"
    fi
}

# Edit a task
function edit_task {
    read -r -p "Nueva tarea: " NEW_TASK
    sed -i "${1}s/.*/- [ ] $NEW_TASK/" "$TODO_FILE"
}

# List all task from file
function list_tasks {
    nl -b a "$TODO_FILE"
    exit 1
}

# List all task files from file
function list_files {
    nl -b a "$CONFIG_FILE"
}

# Function to change workspace (task file)
function change_file {
    LINE_TO_REMOVE=$(grep -nF "$TODO_DIR/$1" "$CONFIG_FILE" | cut -f1 -d:)
    if grep "$TODO_DIR/$1" "$CONFIG_FILE"; then
        # If $1 is in the config file, move it to the top
        { echo "$TODO_DIR/$1"; cat "$CONFIG_FILE"; } > temp && mv temp "$CONFIG_FILE"
        sed -i "$(("$LINE_TO_REMOVE" + 1)) d" "$CONFIG_FILE"
    else
        # If $1 isn't in the config file, add it to the top
        { echo "$TODO_DIR/$1"; cat "$CONFIG_FILE"; } > temp && mv temp "$CONFIG_FILE"
    fi
}

# Set task to blank state
function blank_task {
    sed -i "${1}s/- \[done\]/- \[ \]/" "$TODO_FILE"
}

# Set task to done state
function done_task {
    sed -i "${1}s/- \[ \]/- \[done\]/" "$TODO_FILE"
}

# Parse command line options using getopts
while getopts "a:r:e:f:d:b:lwh" opt; do

    # Check if .todo and default.md exist, if not create them
    if [ ! -d "$TODO_DIR" ]; then
        mkdir -p .todo
    fi

    # Check if config file exist, if not create it
    if [ ! -f "$CONFIG_FILE" ]; then
            touch "$CONFIG_FILE"
    fi

    # Check if config file have content, if not, add default.md to it
    if [ ! -s "$CONFIG_FILE" ]; then
        echo "$TODO_DIR/default.md" >> $CONFIG_FILE
    fi

    # If todo_file isn't on config file add it
    if ! grep -q "$TODO_FILE" "$CONFIG_FILE"; then
        echo "$TODO_FILE" >> "$CONFIG_FILE"
    fi

    # Assign the first line from config_file (latest file used) to todo_file
    TODO_FILE=$(head -n 1 $CONFIG_FILE)

    # Create todo_file if hasn't been created
    if [ ! -f "$TODO_FILE" ]; then
        touch "$TODO_FILE"
    fi

    # Flags 
    case $opt in
        a)
            add_task "$OPTARG"
            ;;
        r)
            remove_task "$OPTARG"
            ;;
        e)
            edit_task "$OPTARG"
            ;;
        f)
            change_file "$OPTARG"
            ;;
        d) 
            done_task "$OPTARG"
            ;;
        b)
            blank_task "$OPTARG"
            ;;
        w)
            list_files 
            ;;
        l)
            list_tasks
            ;;
        h)
            show_help
            ;;
        \?)
            echo "Opción inválida: $1"
            ;;
    esac
done