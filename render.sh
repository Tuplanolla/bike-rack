#! /bin/sh

openscad --camera 300,360,100,60,0,60,4500 --imgsize 800,800 \
  --view axes,crosshairs,scales -o rack.png rack.scad
