SHELL   := /bin/bash
TOPO    := topologia.clab.yml
BRIDGES := sw-servicos sw-gerencia sw-filial
C       := clab-cafeplanalto

.PHONY: build bridges up down test

build:
	docker build -t cafeplanalto/roteador:latest docker/roteador
	docker build -t cafeplanalto/host:latest docker/host
	docker build -t cafeplanalto/dns:latest docker/dns

bridges:
	sudo -v
	for b in $(BRIDGES); do \
		ip link show $$b >/dev/null 2>&1 || sudo ip link add name $$b type bridge; \
		sudo ip link set $$b up; \
	done
	sudo iptables -C FORWARD -i sw-+ -o sw-+ -j ACCEPT 2>/dev/null || \
		sudo iptables -I FORWARD -i sw-+ -o sw-+ -j ACCEPT

up: build bridges
	sudo containerlab deploy -t $(TOPO) --reconfigure

down:
	-sudo containerlab destroy -t $(TOPO) --cleanup
	-@for b in $(BRIDGES); do sudo ip link del $$b 2>/dev/null; done

test:
	@echo "=== traceroute filial -> web ==="
	docker exec $(C)-cliente-carga traceroute -n 172.20.10.20
	@echo "=== DNS a partir da filial ==="
	docker exec $(C)-cliente-carga dig +short loja.cafeplanalto.lab
	@echo "=== ping filial -> db ==="
	docker exec $(C)-cliente-carga ping -c 2 172.20.10.22