docker login -u riuvshin -p 80b1iXVCBomYVmyAmvV2
# if you want to push images, login as user with access to eclipse org hub.docker.com account
cd $(pwd)/recipes/stack-base/debian

docker build -t eclipse/stack-base:debian .
cd ../../..
cd $(pwd)/recipes/stack-base/ubuntu
docker build -t eclipse/stack-base:ubuntu .
cd ../../..
cd $(pwd)/recipes/debian_jdk8
docker build -t eclipse/debian_jdk8 .
cd ../..
cd $(pwd)/recipes/ubuntu_jdk8
docker build -t eclipse/ubuntu_jdk8 .
cd ../..
cd $(pwd)/recipes/ubuntu_python/2.7
docker build -t eclipse/ubuntu_python:2.7 .

cd ../..
dir=$(find . -maxdepth 3 -mindepth 1 -type d -not -path '*/\.*' -exec bash -c 'cd "$0" && pwd' {} \;)

for d in $dir
    do
	IMAGE=$(echo $d | sed 's/.*recipes\///' | awk -F'/' '{print $1}')
	TAG=$(echo $d | sed 's/.*recipes\///' | awk -F'/' '{print $2}')
	    if [ -n "$TAG" ]; then
	    TAG=$TAG
	    else
	    TAG="latest"
	fi
	    cd $d
	if [ ! -f $d/Dockerfile ]; then
	    echo "No Dockerfile Found. Skipping..."
	
	else
	    docker build -t eclipse/"$IMAGE":"$TAG"  .
    		if [ "$?" != "0" ]; then
		    echo "Unable to build image: $IMAGE"
		exit $?
		else
		    echo "$IMAGE:$TAG successfully built"
		    docker push eclipse/"$IMAGE":"$TAG"
    fi
fi
done
