#!/bin/bash -e 

echo -n "Compiling... "

asm6f -q Project.asm Project.nes

echo "Done."

