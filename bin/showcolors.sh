#!/usr/bin/env bash
for fore in `seq 30 37`;
    do printf "\e[${fore}m \\\e[${fore}m \e[m\n";
    for mode in 1 2 4 5 7 8;
        do printf "\e[${fore};${mode}m \\\e[${fore};${mode}m \e[m";
        for back in `seq 40 47`;
            do printf "\e[${fore};${back};${mode}m \\\e[${fore};${back};${mode}m\\\e[m \e[m";
        done;
        echo;
    done;
done;
