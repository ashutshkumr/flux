package main

import (
	"log"

	"github.com/ashutshkumr/flux/pkg/io"
)

func main() {
	d, err := io.NewNetworkDevice("veth1")
	if err != nil {
		log.Fatal(err)
	}

	defer d.Close()

	d.SendBytes([]byte{
		0x00, 0x00, 0x00, 0x00, 0x00, 0xAA,
		0x00, 0x00, 0x00, 0x00, 0x00, 0xBB,
		0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00,
	})
}
