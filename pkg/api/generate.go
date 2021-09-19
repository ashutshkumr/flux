package api

//go:generate go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
//go:generate go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0
//go:generate protoc --plugin=$HOME/go/bin/protoc-gen-go --plugin=$HOME/go/bin/protoc-gen-go-grpc -I=. --go_out=. --go-grpc_out=. api.proto
