awscli ec2 describe-key-pairs --output table --query "KeyPairs[$(auto_filter KeyName KeyFingerprint -- $@)].{\"1.Name\":KeyName,\"2.Fingerprint\":KeyFingerprint}"