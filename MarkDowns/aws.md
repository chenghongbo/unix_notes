aws ec2 create-volume --size 40 --region cn-north-1 --availability-zone cn-north-1b --volume-type gp2
aws ec2 create-snapshot --volume-id vol-1234567890abcdef0 --description "This is my root volume snapshot."
aws ec2 describe-instances --filters Name=private-ip-address,Values=172.31.18.88 --region cn-north-1
aws ec2 start-instances --instance-ids i-02b5042854d7c36fb --region cn-north-1
aws ec2 modify-volume --region cn-north-1 --volume-id vol-0f203ba9f58d7ea3a --size 60 --volume-type gp2
