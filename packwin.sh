#! /bin/bash
#set -x
NAME="pingtunnel"

export GO111MODULE=off

#go tool dist list
build_list=$(go tool dist list)

rm pack -rf
rm pack.zip -f
mkdir pack

go get -u -v github.com/esrrhs/pingtunnel/...
last=`pwd`
cd $GOPATH/src/golang.org/x
for dir in `ls`; do
  cd $dir
  git pull
  cd ..
done
cd $last

for line in $build_list; do
  os="windows"
  arch="amd64"
  echo "os="$os" arch="$arch" start build"
  if [ $os == "android" ]; then
    continue
  fi
  if [ $os == "ios" ]; then
    continue
  fi
  if [ $arch == "wasm" ]; then
    continue
  fi
  CGO_ENABLED=0 GOOS=$os GOARCH=$arch go build -ldflags="-s -w"
  if [ $? -ne 0 ]; then
    echo "os="$os" arch="$arch" build fail"
    exit 1
  fi
  if [ $os = "windows" ]; then
    zip ${NAME}_"${os}"_"${arch}"".zip" $NAME".exe"
    if [ $? -ne 0 ]; then
      echo "os="$os" arch="$arch" zip fail"
      exit 1
    fi
    mv ${NAME}_"${os}"_"${arch}"".zip" pack/
    rm $NAME".exe" -f
  else
    zip ${NAME}_"${os}"_"${arch}"".zip" $NAME
    if [ $? -ne 0 ]; then
      echo "os="$os" arch="$arch" zip fail"
      exit 1
    fi
    mv ${NAME}_"${os}"_"${arch}"".zip" pack/
    rm $NAME -f
  fi
  echo "os="$os" arch="$arch" done build"
done

zip pack.zip pack/ -r

echo "all done"
