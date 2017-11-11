docker build -t elm-build -f Dockerfile.build .



docker build -t elm-build -f Dockerfile.build .
docker create -t -i --name build-container elm-build
docker cp build-container:/app/build.tar.gz .
docker rm -f build-container
docker build -t elm-release -f Dockerfile.release .
exec docker run -it -p 127.0.0.1:8000:8000 elm-release 

