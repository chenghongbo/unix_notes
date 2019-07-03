once the sender receives three duplicate acknowledgments, it will immediately retransmit the missing packet instead of waiting for a timer to expire. These are called fast retransmissions.

Sending TCP sockets usually transmit data in a series. Rather than sending one segment of data at a time and waiting for an acknowledgement, transmitting stations will send several packets in succession. If one of these packets in the stream goes missing, the receiving socket can indicate which packet was lost using selective acknowledgments.

These allow the receiver to continue to acknowledge incoming data while informing the sender of the missing packet(s) in the stream.

As shown above, selective acknowledgements will use the ACK number in the TCP header to indicate which packet was lost. At the same time, in these ACK packets, the receiver can use the SACK option in the TCP header to show which packets have been successfully received after the point of loss.
