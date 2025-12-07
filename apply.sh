#!/bin/bash
stow --no-folding --target=/home/$USER --adopt home
git restore .