DIR=$(cd "$(dirname "$0")"; pwd)
echo "Compiling from $DIR directory"
cd $DIR
./node_modules/typescript/bin/tsc --project .

