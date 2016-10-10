@echo off
echo "Compiling from directory %cd%"
docker run --rm -v %cd%:/usr/src/app -w /usr/src/app node:6 /bin/bash -c "cd /usr/src/app/dependencies/runtime && npm install -no-bin-links && cd /usr/src/app && npm install -no-bin-links && cd /usr/src/app/src && find . -name "*.properties" -exec install -D {} /usr/src/app/lib/{} \; && cd /usr/src/app && /usr/src/app/node_modules/typescript/bin/tsc --project /usr/src/app"
