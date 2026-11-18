FROM alpine:3.20
RUN apk add --no-cache net-snmp net-snmp-tools iproute2 iproute2-tc \
    iputils traceroute tcpdump curl bind-tools
COPY snmpd.conf /etc/snmp/snmpd.conf
CMD ["sleep", "infinity"]