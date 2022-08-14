#!/bin/bash
#monitored host address
PUSH_HOST=epamrt

#prometheus push gateway address
PUSH_GW=epamweb

#TCP connections established counter
NET_CONN_ESTB=`netstat -s |grep -i 'connections established' |awk {'print $1'}`

#send amount of established connections to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_connections_estb counter
#HELP net_connections_estb Shows established TCP connections
net_connections_estb $NET_CONN_ESTB
EOF


#forwarded packets counter
NET_FORW_CNT=`netstat -s |grep forwarded |awk {'print $1'}`

#send forwarded packets counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_forward_counter counter
#HELP net_forward_counter Shows forwarded packets
net_forward_counter $NET_FORW_CNT
EOF


#ip total packets received counter
NET_TOTAL_INKPKTS=`netstat -s |grep -i 'total packets received' |awk {'print $1'}`

#send total packets received counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_total_packets_received counter
#HELP net_total_packets_received Shows total packets received
net_total_packets_received $NET_TOTAL_INKPKTS
EOF


#ip total sent packets counter
NET_OUTPKTS=`netstat -s |grep -i 'requests sent out' |awk {'print $1'}`
#sum with forwarded
NET_OUTPKTS_TOTAL=$((NET_OUTPKTS+NET_FORW_CNT))

#send total packets sent counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_total_packets_sent counter
#HELP net_total_packets_sent Shows total packets sent
net_total_packets_sent $NET_OUTPKTS_TOTAL
EOF


#ip dropped packets counter
NET_PKTS_DROPPED=`netstat -s |grep -i 'outgoing packets dropped' |awk {'print $1'}`
NET_PKTS_DROPPED_RT=`netstat -s |grep -i 'dropped because of missing route' |awk {'print $1'}`
NET_PKTS_DROPPED_EST=`netstat -s |grep -i 'rejected in established connections' |awk {'print $1'}`
NET_PKTS_DROPPED_IN=`netstat -s |grep -i 'packets discarded' |awk {'print $1'}`
#sum
NET_PKTS_DROPPED_TOTAL=$((NET_PKTS_DROPPED+NET_PKTS_DROPPED_RT+NET_PKTS_DROPPED_EST+NET_PKTS_DROPPED_IN))

#send total dropped packets counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_total_packets_dropped counter
#HELP net_total_packets_dropped Shows total packets dropped
net_total_packets_dropped $NET_PKTS_DROPPED_TOTAL
EOF


#Interface errors
NET_INT_IN_ERR=`netstat -i |tail -n +3|awk {'print $4'} |awk '{s+=$1}END{print s}'`
NET_INT_OUT_ERR=`netstat -i |tail -n +3|awk {'print $8'} |awk '{s+=$1}END{print s}'`

#sum
NET_INT_ERR_TOTAL=$((NET_INT_IN_ERR+NET_INT_OUT_ERR))

#send errors counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_total_errors counter
#HELP net_total_errors Shows total errors for all interfaces
net_total_errors $NET_INT_ERR_TOTAL
EOF


#Broadcast bytes received
NET_BCAST_IN=`nstat -z -a -s |grep IpExtInBcastOctets|awk {'print $2'}`

#send broadcast received bytes counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_broadcast_in counter
#HELP net_broadcast_in Shows received broadcast bytes
net_broadcast_in $NET_BCAST_IN
EOF


#Broadcast bytes sent
NET_BCAST_OUT=`nstat -z -a -s |grep IpExtOutBcastOctets|awk {'print $2'}`

#send broadcast sent bytes counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_broadcast_out counter
#HELP net_broadcast_out Shows sent broadcast bytes
net_broadcast_out $NET_BCAST_OUT
EOF


#Multicast bytes received
NET_MCAST_IN=`nstat -z -a -s |grep IpExtInMcastOctets|awk {'print $2'}`

#send multicast received bytes counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_multicast_in counter
#HELP net_multicast_in Shows received multicast bytes
net_multicast_in $NET_MCAST_IN
EOF


#Multicast bytes sent
NET_MCAST_OUT=`nstat -z -a -s |grep IpExtOutMcastOctets|awk {'print $2'}`

#send multicast sent bytes counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_multicast_out counter
#HELP net_multicast_out Shows sent multicast bytes
net_multicast_out $NET_MCAST_OUT
EOF


#Total bytes received
NET_TOTAL_BYTES_IN=`nstat -z -a -s |grep IpExtInOctets|awk {'print $2'}`

#send total bytes received counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_total_bytes_in counter
#HELP net_total_bytes_in Shows total bytes received
net_total_bytes_in $NET_TOTAL_BYTES_IN
EOF


#Total bytes sent
NET_TOTAL_BYTES_OUT=`nstat -z -a -s |grep IpExtOutOctets|awk {'print $2'}`

#send total bytes sent counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_total_bytes_out counter
#HELP net_total_bytes_out Shows total bytes received
net_total_bytes_out $NET_TOTAL_BYTES_OUT
EOF


#calculate unicast bytes received
NET_UNICAST_BYTES_IN=$((NET_TOTAL_BYTES_IN-NET_BCAST_IN-NET_MCAST_IN))

#calculate unicast bytes sent
NET_UNICAST_BYTES_OUT=$((NET_TOTAL_BYTES_OUT-NET_BCAST_OUT-NET_MCAST_OUT))

#send unicast bytes counters to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_unicast_bytes_out counter
#HELP net_unicast_bytes_out Shows unicast bytes sent
net_unicast_bytes_out $NET_UNICAST_BYTES_OUT

#TYPE net_unicast_bytes_in counter
#HELP net_unicast_bytes_in Shows unicast bytes received
net_unicast_bytes_in $NET_UNICAST_BYTES_IN
EOF


#NAT connections
NET_NAT_CONN=`conntrack -L -j 2>&1 |grep -v conntrack |wc -l`

#send NAT connections counter to the gateway
cat <<EOF | curl -m 5 --data-binary @- http://$PUSH_GW:9091/metrics/job/pushgateway/instance/$PUSH_HOST
#TYPE net_nat_conn counter
#HELP net_nat_conn Shows NAT connections
net_nat_conn $NET_NAT_CONN
EOF
