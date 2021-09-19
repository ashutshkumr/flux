#!/bin/sh

GOPATH=/home/go

GO_VERSION=1.17
PROTOC_VERSION=3.18.0

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
    apt-get update \
	&& apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get -y install curl git ssh vim unzip \
    && get_protoc \
    && get_go \
    && get_go_deps
}

get_go() {
    echo "Installing Go ..."
    # install golang per https://golang.org/doc/install#tarball
    curl -kL https://dl.google.com/go/${GO_TARGZ} | tar -C /usr/local/ -xzf -
}

get_go_deps() {
    # download all dependencies mentioned in go.mod
    echo "Dowloading go test mod dependencies ..."
    go mod download
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0
    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
}

get_protoc() {  
    echo "\nInstalling protoc ...\n"
    # install protoc per https://github.com/protocolbuffers/protobuf#protocol-compiler-installation
    curl -kL -o protoc.zip \
        https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC_ZIP} \
    && unzip protoc.zip -d /usr/local \
    && rm -rf ./protoc.zip
}

gen_stubs() {
    protoc -I=pkg/api --go_out=pkg/api --go-grpc_out=pkg/api pkg/api/*.proto
}

case $1 in
    deps   )
        install_deps
        ;;
    gen  )
        gen_stubs
        ;;
	*		)
        $1 || echo "usage: $0 [deps|gen]"
		;;
esac
