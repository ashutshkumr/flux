package main

import (
	"log"

	"github.com/ashutshkumr/flux/pkg/api"
)

func main() {
	req := api.GetStatsRequest{
		Port: &api.PortStatQuery{
			Names: []string{},
			Keys: []api.PortStatQuery_Key{
				api.PortStatQuery_BITS_RX,
				api.PortStatQuery_BITS_TX,
			},
		},
	}

	log.Println(req.String())
}
