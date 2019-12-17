ISTIO_VERSION?=1.1.13
ISTIO_NAMESPACE=istio-system
ISTIO_INGRESS_NAME=istio-ingressgateway
ISTIO_LB_IP=10.0.44.53

help: help.variables help.available_functions

help.variables:
	@echo "================================="
	@echo "Variables for Istio Installation"
	@echo ${ISTIO_VERSION}
	@echo ${ISTIO_NAMESPACE}
	@echo ${ISTIO_INGRESS_NAME}
	@echo ${ISTIO_LB_IP}

help.available_functions:
	@echo "================================="
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

istio.download: ## Download Istio from github, version as per ${ISTIO_VERSION}
	@echo "Download Istio"
	@curl -L https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-linux.tar.gz | tar xz

k8s.create_namespace: ## Create istio-system namespace #TO_DO: check if exists then create, else message user
	@kubectl create namespace ${ISTIO_NAMESPACE}

k8s.create_ca: ## Copy K8S CA to istio-system namespace
	@echo "Copy CA to istio-system namespace"
	@kubectl get secret istio-ca-secret --namespace=kube-system --export -o yaml | kubectl apply --validate=false --namespace=istio-system -f -

istio.init: ## Initialise Istio CRD's
	@echo "Init Istio CRD's"
	@helm template istio-${ISTIO_VERSION}/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -

istio.install: ## Install Istio
	@helm template istio-${ISTIO_VERSION}/install/kubernetes/helm/istio --name istio --namespace istio-system | kubectl apply -f -

istio.patch_lb: ## Patch Istio Ingress Service with F5 IP for LoadBalancer IP
	kubectl patch svc ${ISTIO_INGRESS_NAME} -n istio-system --patch 'spec:\n  loadBalancerIP: ${ISTIO_LB_IP}'

istio.partial_install: k8s.create_namespace k8s.create_ca istio.init istio.install ## Istio installation excluding Istio Download
	@echo "Partial istio install exc. download"

istio.full_install: istio.download k8s.create_ca istio.init istio.install ## Istio installation including Istio Download
	@echo "Full istio install inc. download"

istio.delete: ## Delete Istio and istio-system namespace
	@helm template istio-${ISTIO_VERSION}/install/kubernetes/helm/istio --name istio --namespace istio-system | kubectl delete -f -
	@kubectl delete namespace ${ISTIO_NAMESPACE}