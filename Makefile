define unit_test
	((curl --silent -v -k -i http://fou.test/hello | grep '200 OK') && \
			echo "HELLO WORLD for Istio $(1) PASSED") || \
		echo "HELLO WORLD for Istio $(1) FAILED"
endef

define unit_test_batch
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
	sleep 10
	$(call unit_test,$(1))
endef

define using_istio
	$(eval HELM_PATH := istio-$(1)/install/kubernetes/helm)
	$(eval K8S_BASE_PATH := istio-$(1)/k8s)

	[[ -r istio-$(1)/.done ]] || (curl --silent -L https://git.io/getLatestIstio | ISTIO_VERSION=$(1) sh -)
	touch istio-$(1)/.done

	kubectl create ns istio-system 2>/dev/null || true
	kubectl create ns fou 2>/dev/null || true
	kubectl label ns fou istio-injection=enabled 2>/dev/null || true

	mkdir -p $(K8S_BASE_PATH)/init
	cp kustomization.yaml $(K8S_BASE_PATH)/init
	mkdir -p $(K8S_BASE_PATH)/main
	cp kustomization.yaml $(K8S_BASE_PATH)/main

	helm template $(HELM_PATH)/istio-init \
		--name istio-init \
		--namespace istio-system \
		> $(K8S_BASE_PATH)/init/template.yaml

	helm template $(HELM_PATH)/istio \
		--name istio --namespace istio-system \
		--values $(HELM_PATH)/istio/values.yaml \
		--set sidecarInjectorWebhook.enabled=true \
		--set sidecarInjectorWebhook.rewriteAppHTTPProbe=true \
		--set global.mtls.enabled=false \
		--set global.controlPlaneSecurity=false \
		--set global.proxy.accessLogFile="/dev/stdout" \
		--set global.tracer.zipkin.address=jaeger-collector.monitoring:9411 \
		--set global.gateways.enabled=false \
		--set global.k8sIngress.enabled=false \
		--set gateways.istio-ingressgateway.enabled=false \
		--set pilot.traceSampling=100.0 \
		--set kiali.enabled=false \
		--set grafana.enabled=false \
		> $(K8S_BASE_PATH)/main/template.yaml

	kubectl apply -k $(K8S_BASE_PATH)/init
	kubectl apply -k ./nginx-ingress
	sleep 10
	kubectl apply -k $(K8S_BASE_PATH)/main
	kubectl apply -f dr.yaml # default to mTLS for *.local hosts
	sleep 8
	kubectl apply -k ./helloworld

	$(call unit_test_batch,$(1))
endef

.PHONY: istio_1_2_8
istio_1_2_8:
	$(call using_istio,1.2.8)

.PHONY: istio_1_3_3
istio_1_3_3:
	$(call using_istio,1.3.3)

.PHONY: istio_1_3_4
istio_1_3_4:
	$(call using_istio,1.3.4)

.PHONY: istio_1_4_0_beta_1
istio_1_4_0_beta_1:
	$(call using_istio,1.4.0-beta.1)

.PHONY: test
test:
	$(call unit_test_batch)

.PHONY: delete
delete:
	kubectl apply -k $(K8S_BASE_PATH)/init
	kubectl apply -k ./nginx-ingress
	kubectl apply -k $(K8S_BASE_PATH)/main
	kubectl apply -k ./helloworld

.PHONY: events
events:
	kubectl get events --all-namespaces -w

.PHONY: logs
logs:
	kubectl logs -f -l app.kubernetes.io/name=ingress-nginx -n ingress-nginx