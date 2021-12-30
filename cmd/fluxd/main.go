package main

import (
	"context"
	"log"
	"net"

	"github.com/ashutshkumr/flux/pkg/api"
	"github.com/ashutshkumr/flux/pkg/io"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type server struct {
	api.UnimplementedFluxServiceServer
}

func main() {
	lis, err := net.Listen("tcp", "localhost:5000")
	if err != nil {
		log.Fatal(err)
	}

	svr := grpc.NewServer()
	api.RegisterFluxServiceServer(svr, &server{})
	log.Println("Listening on localhost:5000 ...")
	if err := svr.Serve(lis); err != nil {
		log.Fatal(err)
	}
}

func (s *server) SetConfig(ctx context.Context, in *api.SetConfigRequest) (*api.SetConfigResponse, error) {
	out := &api.SetConfigResponse{}

	d, err := io.NewNetworkDevice(in.Ports[0].Ifc)
	if err != nil {
		out.Errors = []string{err.Error()}
		return out, nil
	}
	defer d.Close()

	err = d.SendBytes(in.Flows[0].Headers[0].Raw.Bytes)
	if err != nil {
		out.Errors = []string{err.Error()}
		return out, nil
	}

	return out, nil
}
func (s *server) SetState(ctx context.Context, in *api.SetStateRequest) (*api.SetStateResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method SetState not implemented")
}
func (s *server) GetStats(ctx context.Context, in *api.GetStatsRequest) (*api.GetStatsResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method GetStats not implemented")
}
