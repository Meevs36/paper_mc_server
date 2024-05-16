#! /bin/bash
# Author -- meevs
# Creation Date -- 2023-11-03
# File Name -- init_container.sh
# Notes --

echo -e "<<INFO>> -- Server is running out of \"\e[38;2;200;200;0m${INSTALL_DIR}\e[0m\""
echo -e "<<INFO>> -- Plugin directory is \"\e[38;2;200;200;0m${INSTALL_DIR}/plugins\e[0m\""

# If no paper build version has been specified
if [[ -z "${PAPER_BUILD_VERSION}" ]]
then
	echo -e "<<INFO>> -- Checking for latest Paper build..."
	# Check for updated server software (only if no specific build version has been specified)
	RESPONSE=$(curl -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}" -H 'accept: application/json')
	
	BUILD_COUNT=$(echo "${RESPONSE}" | jq .builds | jq length)
	echo -e "<<INFO>> -- Found ${BUILD_COUNT} builds for version ${MC_VERSION}"
	export PAPER_BUILD_VERSION=$(echo "${RESPONSE}" | jq .builds[$((BUILD_COUNT - 1))])
	echo -e "<<INFO>> -- Latest Paper build is \e[38;2;200;200;0m${PAPER_BUILD_VERSION}\e[0m"
fi

# Check if this version is already downloaded
if [[ -f "${BUILD_DIR}/paper_mc-${MC_VERSION}-${PAPER_BUILD_VERSION}.jar" || -f "./paper_mc-${MC_VERSION}-${PAPER_BUILD_VERSION}.jar" ]]
then
	echo -e "\e[38;2;0;200;0m<<INFO>> -- Latest version is already downloaded!\e[0m"
else
	echo -e "<<INFO>> -- Downloading \e[38;2;200;200;0mv${MC_VERSION}\e[0m build \e[38;2;200;200;0m${PAPER_BUILD_VERSION}...\e[0m"
	# If version is not downloaded, get latest version
	curl --location "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds/${PAPER_BUILD_VERSION}/downloads/paper-${MC_VERSION}-${PAPER_BUILD_VERSION}.jar" --output "${BUILD_DIR}/paper_mc-${MC_VERSION}-${PAPER_BUILD_VERSION}.jar"
	echo -e "\e[38;2;0;200;0m<<INFO>> -- Download of v${MC_VERSION} build ${PAPER_BUILD_VERSION} successful!\e[0m"
fi

# Check if initial setup has been done
if [[ ! -f "./paper_mc-${MC_VERSION}-${PAPER_BUILD_VERSION}.jar" ]]
then
	echo "<<INFO>> -- Initializating server..."
	cp -v /tmp/paper_mc/start_server.sh ./
	cp -v "${BUILD_DIR}/paper_mc-${MC_VERSION}-${PAPER_BUILD_VERSION}.jar" ./
fi

# Ensure EULA exists
echo -e "\e[38;2;200;200;0m<<INFO>> -- Setting to EULA to ${MC_EULA}\e[0m"
echo "eula=${MC_EULA}" > ./eula.txt

# Start server
./start_server.sh
