all: fluxd

fluxd:
	CGO_ENABLED=0 go build -o cmd/fluxd/fluxd cmd/fluxd/main.go
	sudo cmd/fluxd/fluxd

clean:
	rm -rf cmd/fluxd/fluxd
