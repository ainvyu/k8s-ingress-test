test:
	curl $$(kubectl get service --namespace=kube-system --output json | jq -r '.items[].status.loadBalancer.ingress[0].hostname' | grep -v null | sort | uniq)/1
	curl $$(kubectl get service --namespace=kube-system --output json | jq -r '.items[].status.loadBalancer.ingress[0].hostname' | grep -v null | sort | uniq)/2
