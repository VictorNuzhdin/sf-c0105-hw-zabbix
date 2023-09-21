#!/bin/bash


## Adds fake changes to repo (something like "repos-is-alive" beakon)
## *examples (execution from repo root):
##  $ ./scripts/make_fake_changes.sh 
#
#..make changes
LOG_FILE=logs/fake.log
echo "[$(date +'%Y-%m-%d %H:%M:%S')] :: fake changes v$(date +'%Y%m%d_%H%M%S')" >> $LOG_FILE
#
#..send changes to repo
clear
git status
echo ---
git add .
git commit -m "Fake changes"
git push
echo ---
git status
