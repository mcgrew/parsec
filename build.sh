#!/bin/bash -e 

echo -n "Compiling... "

asm6f -q -dDEBUG parsec.asm parsec.nes

echo "Done."

