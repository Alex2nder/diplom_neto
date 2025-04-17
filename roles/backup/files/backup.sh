#!/bin/bash

# Script to create snapshot of disk
yc compute snapshot create --folder-id {{ folder_id }} --name web-snapshot --description "Snapshot of web server disk"
