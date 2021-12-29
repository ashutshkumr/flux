package io

import (
	"fmt"
	"log"
	"net"

	"golang.org/x/sys/unix"
)

type NetworkDeviceOpts struct{}

type NetworkDevice interface {
	SendBytes(bytes []byte) error
	ReceiveBytes() ([]byte, error)
	SetOpts(opts *NetworkDeviceOpts) error
	Close() error
}

type unixNwDevice struct {
	name     string
	sock     int
	sockAddr *unix.SockaddrLinklayer
	opts     *NetworkDeviceOpts
	netIfc   *net.Interface
}

func NewNetworkDevice(name string) (_ NetworkDevice, err error) {
	log.Printf("Binding to network device %s ...\n", name)

	dev := &unixNwDevice{
		name: name,
	}

	dev.netIfc, err = net.InterfaceByName(name)
	if err != nil {
		return nil, fmt.Errorf("could not find network device by name %s: %v", dev.name, err)
	}

	// create socket
	dev.sock, err = unix.Socket(unix.AF_PACKET, unix.SOCK_RAW, unix.ETH_P_ALL)
	if err != nil {
		return nil, fmt.Errorf("could not create socket for network device %s: %v", dev.name, err)
	}
	// make socket non-blocking
	err = unix.SetNonblock(dev.sock, true)
	if err != nil {
		dev.Close()
		return nil, fmt.Errorf("could not set socket to non-blocking for network device %s: %v", dev.name, err)
	}

	dev.sockAddr = &unix.SockaddrLinklayer{
		Protocol: unix.ETH_P_ALL,
		Ifindex:  dev.netIfc.Index,
	}
	err = unix.Bind(dev.sock, dev.sockAddr)
	if err != nil {
		dev.Close()
		return nil, fmt.Errorf("could not bind to network device %s: %v", dev.name, err)
	}

	return dev, err
}

func (d *unixNwDevice) SendBytes(bytes []byte) error {
	_, err := unix.Write(d.sock, bytes)
	if err != nil {
		return fmt.Errorf("could not send bytes: %v", err)
	}
	return nil
}

func (d *unixNwDevice) ReceiveBytes() ([]byte, error) {
	return nil, nil
}

func (d *unixNwDevice) SetOpts(opts *NetworkDeviceOpts) error {
	return nil
}

func (d *unixNwDevice) Close() error {
	log.Printf("Closing network device %s ...\n", d.name)
	return unix.Close(d.sock)
}
