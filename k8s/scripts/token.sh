#!/bin/bash

kubeadm certs certificate-key | tee /tmp/key.txt
kubeadm init phase upload-certs --upload-certs --certificate-key "$(cat /tmp/key.txt)"
kubeadm token create --print-join-command > /tmp/joincommand.txt
cat /tmp/joincommand.txt | sed -nE 's/.*token (.*) --discovery.*$/\1/p' | tee /tmp/token.txt
cat /tmp/joincommand.txt | sed -nE 's/.*cert-hash sha256:(.*)$/\1/p' | tee /tmp/hash.txt
