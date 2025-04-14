#!/bin/sh
cd "/home/diver/Games/wc/CircleL/Interface/AddOns/NSQC3/"
j=$(date)
git add .
git commit -m "$1 $j"
git push git@github.com:Vladgobelen/NSQC3.git


