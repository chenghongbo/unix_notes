See the list of interfaces on which tcpdump can listen:

	tcpdump -D

Listen on interface eth0:

	tcpdump -i eth0

Listen on any available interface (cannot be done in promiscuous mode. Requires Linux kernel 2.2 or greater):

	tcpdump -i any
	
Be verbose while capturing packets:

	tcpdump -v
Be more verbose while capturing packets:

	tcpdump -vv
Be very verbose while capturing packets:

	tcpdump -vvv
Be verbose and print the data of each packet in both hex and ASCII, excluding the link level header:

	tcpdump -v -X
Be verbose and print the data of each packet in both hex and ASCII, also including the link level header:

	tcpdump -v -XX
Be less verbose (than the default) while capturing packets:
https://www.google.com.hk/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0ahUKEwi41-ncjqTVAhXMl5QKHcdHAU8QFggjMAA&url=http%3A%2F%2Fwww.tomsitpro.com%2Farticles%2Fflash-data-center-advantages%2C2-744-2.html&usg=AFQjCNEJxAM7407yKQn7KabKjT7FwvmIdA
	tcpdump -q
Limit the capture to 100 packets:

	tcpdump -c 100
Record the packet capture to a file called capture.cap:

	tcpdump -w capture.cap
Record the packet capture to a file called capture.cap but display on-screen how many packets have been captured in real-time:

	tcpdump -v -w capture.cap
Display the packets of a file called capture.cap:

	tcpdump -r capture.cap
Display the packets using maximum detail of a file called capture.cap:

	tcpdump -vvv -r capture.cap
Display IP addresses and port numbers instead of domain and service names when capturing packets (note: on some systems you need to specify -nn to display port numbers):

	tcpdump -n
Capture any packets where the destination host is 192.168.1.1. Display IP addresses and port numbers:

	tcpdump -n dst host 192.168.1.1
Capture any packets where the source host is 192.168.1.1. Display IP addresses and port numbers:

	tcpdump -n src host 192.168.1.1
Capture any packets where the source or destination host is 192.168.1.1. Display IP addresses and port numbers:

	tcpdump -n host 192.168.1.1
Capture any packets where the destination network is 192.168.1.0/24. Display IP addresses and port numbers:

	tcpdump -n dst net 192.168.1.0/24
Capture any packets where the source network is 192.168.1.0/24. Display IP addresses and port numbers:

	tcpdump -n src net 192.168.1.0/24
Capture any packets where the source or destination network is 192.168.1.0/24. Display IP addresses and port numbers:

	tcpdump -n net 192.168.1.0/24
Capture any packets where the destination port is 23. Display IP addresses and port numbers:

	tcpdump -n dst port 23
Capture any packets where the destination port is is between 1 and 1023 inclusive. Display IP addresses and port numbers:

	tcpdump -n dst portrange 1-1023
Capture only TCP packets where the destination port is is between 1 and 1023 inclusive. Display IP addresses and port numbers:

	tcpdump -n tcp dst portrange 1-1023
Capture only UDP packets where the destination port is is between 1 and 1023 inclusive. Display IP addresses and port numbers:

	tcpdump -n udp dst portrange 1-1023
Capture any packets with destination IP 192.168.1.1 and destination port 23. Display IP addresses and port numbers:

	tcpdump -n "dst host 192.168.1.1 and dst port 23"
Capture any packets with destination IP 192.168.1.1 and destination port 80 or 443. Display IP addresses and port numbers:

	tcpdump -n "dst host 192.168.1.1 and (dst port 80 or dst port 443)"
Capture any ICMP packets:

	tcpdump -v icmp
Capture any ARP packets:

	tcpdump -v arp
Capture either ICMP or ARP packets:

	tcpdump -v "icmp or arp"
Capture any packets that are broadcast or multicast:

	tcpdump -n "broadcast or multicast"
Capture 500 bytes of data for each packet rather than the default of 68 bytes:

	tcpdump -s 500
Capture all bytes of data within the packet:

	tcpdump -s 0