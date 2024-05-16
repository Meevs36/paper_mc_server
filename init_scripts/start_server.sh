#! /bin/sh
# Author -- meevs
# Creation Date -- 2023-03-11
# File Name -- start_server.sh
# Notes --

echo -e "\e[38;2;0;200;0m<<INFO>> -- Starting server...\e[0m"
java -Xms"${MIN_RAM}" -Xmx"${MAX_RAM}" -jar "./paper_mc-${MC_VERSION}-${PAPER_BUILD_VERSION}.jar" nogui
echo -e "\e[38;2;0;200;0m<<INFO>> -- Server has stopped...\e[0m"

