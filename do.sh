#!/bin/sh

GOPATH=/home/go

GO_VERSION=1.17
PROTOC_VERSION=3.18.0

set -e

if [ ! -f "$HOME/.env" ]
then
    touch $HOME/.env
    out='[ -f "$HOME/.env" ] && . "$HOME/.env"'
    echo $out >> $HOME/.profile
    echo $out >> $HOME/.bashrc
fi
# source path for current session
. $HOME/.env

# Avoid warnings for non-interactive apt-get install
export DEBIAN_FRONTEND=noninteractive

# get installers based on host architecture
if [ "$(arch)" = "aarch64" ] || [ "$(arch)" = "arm64" ]
then
    echo "Host architecture is ARM64"
    GO_TARGZ=go${GO_VERSION}.linux-arm64.tar.gz
    PROTOC_ZIP=protoc-${PROTOC_VERSION}-linux-aarch_64.zip
elif [ "$(arch)" = "x86_64" ]
then
    echo "Host architecture is x86_64"
    GO_TARGZ=go${GO_VERSION}.linux-amd64.tar.gz
    PROTOC_ZIP=protoc-${PROTOC_VERSION}-linux-x86_64.zip
else
    echo "Host architecture $(arch) is not supported"
    exit 1
fi

install_deps() {
	# Dependencies required by this project
    echo "Installing Dependencies ..."
    sudo apt-get update
	sudo apt-get install -y --no-install-recommends curl git ssh vim unzip
    get_protoc
    get_go
    get_go_deps
}

get_go() {
    go version 2> /dev/null && return
    cecho "Installing Go ..."
    # install golang per https://golang.org/doc/install#tarball
    curl -kL https://dl.google.com/go/${GO_TARGZ} | sudo tar -C /usr/local/ -xzf -
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.env
    # source path for current session
    . $HOME/.env

    go version
}

get_go_deps() {
    # download all dependencies mentioned in go.mod
    echo "Dowloading go test mod dependencies ..."
    go mod download
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0
    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
}

get_protoc() {
    curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC_ZIP}
    rm -rf $HOME/.local
    unzip ${PROTOC_ZIP} -d $HOME/.local
    rm -f ${PROTOC_ZIP}
    echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.env
    # source path for current session
    . $HOME/.env
    protoc --version
}

gen_stubs() {
    protoc -I=pkg/api --go_out=pkg/api --go-grpc_out=pkg/api pkg/api/*.proto
}

build() {
    go build -o cmd/fluxd/fluxd cmd/fluxd/main.go
    go build -o cmd/fluxc/fluxc cmd/fluxc/main.go
}

clean() {
    rm -rf cmd/fluxd/fluxd cmd/fluxd/fluxc
}

run() {
    build
    sudo cmd/fluxd/fluxd
}

case $1 in
	*		)
        $1 || echo "usage: $0 [name of any function in script]"
		;;
esac
