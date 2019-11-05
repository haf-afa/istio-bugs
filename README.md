# Istio Bugs

Istio is very buggy and causes a lot of headaches in dev. This repo is about trying to isolate these bugs in easy-to-reproduce form.

You need:

- Windows
- Docker for Desktop with Kubernetes enabled and resources bumped to ~4 CPUs and ~8 GiB memory
- Make
- Point `fou.test` to `127.0.0.1` in your hosts file.

installed.

Have a look at the Makefile for different targets to run.

Istio-Ingress Gateway was so utterly buggy that it's not even in this repo at the time of writing, so we're using nginx-ingress instead. All routing is between that ingress controller and the helloworld service.

Here's an example run after doing a Kubernetes reset:

```
$ make istio_1_3_4
# if [ -z istio-1.3.4/.done ]; then
test -s istio-1.3.4/.done || (curl --silent -L https://git.io/getLatestIstio | ISTIO_VERSION=1.3.4 sh -)
Downloading istio-1.3.4 from https://github.com/istio/istio/releases/download/1.3.4/istio-1.3.4-linux.tar.gz ...  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   614    0   614    0     0   1245      0 --:--:-- --:--:-- --:--:--  1245
100 36.3M  100 36.3M    0     0  5489k      0  0:00:06  0:00:06 --:--:-- 6195k
Istio 1.3.4 Download Complete!

Istio has been successfully downloaded into the istio-1.3.4 folder on your system.

Next Steps:
See https://istio.io/docs/setup/kubernetes/install/ to add Istio to your Kubernetes cluster.

To configure the istioctl client tool for your workstation,
add the /c/dev/istio-bugs/istio-1.3.4/bin directory to your environment path variable with:
         export PATH="$PATH:/c/dev/istio-bugs/istio-1.3.4/bin"

Begin the Istio pre-installation verification check by running:
         istioctl verify-install

Need more information? Visit https://istio.io/docs/setup/kubernetes/install/
# fi
touch istio-1.3.4/.done
kubectl create ns istio-system 2>/dev/null || true
namespace/istio-system created
kubectl create ns fou 2>/dev/null || true
namespace/fou created
kubectl label ns fou istio-injection=enabled 2>/dev/null || true
namespace/fou labeled
mkdir -p istio-1.3.4/k8s/init
cp kustomization.yaml istio-1.3.4/k8s/init
mkdir -p istio-1.3.4/k8s/main
cp kustomization.yaml istio-1.3.4/k8s/main
helm template istio-1.3.4/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system > istio-1.3.4/k8s/init/template.yaml
helm template istio-1.3.4/install/kubernetes/helm/istio --name istio --namespace istio-system --values istio-1.3.4/install/kubernetes/helm/istio/values.yaml --set sidecarInjectorWebhook.enabled=true --set sidecarInjectorWebhook.rewriteAppHTTPProbe=true --set global.mtls.enabled=true --set global.proxy.accessLogFile="/dev/stdout" --set global.tracer.zipkin.address=jaeger-collector.monitoring:9411 --set global.gateways.enabled=false --set global.k8sIngress.enabled=false --set gateways.istio-ingressgateway.enabled=false --set pilot.traceSampling=100.0 --set kiali.enabled=false --set grafana.enabled=false > istio-1.3.4/k8s/main/template.yaml
kubectl apply -k istio-1.3.4/k8s/init
serviceaccount/istio-init-service-account created
clusterrole.rbac.authorization.k8s.io/istio-init-istio-system created
clusterrolebinding.rbac.authorization.k8s.io/istio-init-admin-role-binding-istio-system created
configmap/istio-crd-10 created
configmap/istio-crd-11 created
configmap/istio-crd-12 created
job.batch/istio-init-crd-10-1.3.4 created
job.batch/istio-init-crd-11-1.3.4 created
job.batch/istio-init-crd-12-1.3.4 created
kubectl apply -k ./nginx-ingress
namespace/ingress-nginx created
serviceaccount/nginx-ingress-serviceaccount created
role.rbac.authorization.k8s.io/nginx-ingress-role created
clusterrole.rbac.authorization.k8s.io/nginx-ingress-clusterrole created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-role-nisa-binding created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-clusterrole-nisa-binding created
configmap/nginx-configuration created
configmap/tcp-services created
configmap/udp-services created
service/ingress-nginx created
deployment.apps/nginx-ingress-controller created
sleep 10
kubectl apply -k istio-1.3.4/k8s/main
mutatingwebhookconfiguration.admissionregistration.k8s.io/istio-sidecar-injector created
serviceaccount/istio-citadel-service-account created
serviceaccount/istio-galley-service-account created
serviceaccount/istio-mixer-service-account created
serviceaccount/istio-multi created
serviceaccount/istio-pilot-service-account created
serviceaccount/istio-security-post-install-account created
serviceaccount/istio-sidecar-injector-service-account created
serviceaccount/prometheus created
clusterrole.rbac.authorization.k8s.io/istio-citadel-istio-system created
clusterrole.rbac.authorization.k8s.io/istio-galley-istio-system created
clusterrole.rbac.authorization.k8s.io/istio-mixer-istio-system created
clusterrole.rbac.authorization.k8s.io/istio-pilot-istio-system created
clusterrole.rbac.authorization.k8s.io/istio-reader created
clusterrole.rbac.authorization.k8s.io/istio-sidecar-injector-istio-system created
clusterrole.rbac.authorization.k8s.io/prometheus-istio-system created
clusterrole.rbac.authorization.k8s.io/istio-security-post-install-istio-system created
clusterrolebinding.rbac.authorization.k8s.io/istio-citadel-istio-system created
clusterrolebinding.rbac.authorization.k8s.io/istio-galley-admin-role-binding-istio-system created
clusterrolebinding.rbac.authorization.k8s.io/istio-mixer-admin-role-binding-istio-system created
clusterrolebinding.rbac.authorization.k8s.io/istio-multi created
clusterrolebinding.rbac.authorization.k8s.io/istio-pilot-istio-system created
clusterrolebinding.rbac.authorization.k8s.io/istio-sidecar-injector-admin-role-binding-istio-system created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-istio-system created
clusterrolebinding.rbac.authorization.k8s.io/istio-security-post-install-role-binding-istio-system created
configmap/istio-galley-configuration created
configmap/istio-security-custom-resources created
configmap/istio-sidecar-injector created
configmap/istio created
configmap/prometheus created
service/istio-citadel created
service/istio-galley created
service/istio-pilot created
service/istio-policy created
service/istio-sidecar-injector created
service/istio-telemetry created
service/prometheus created
deployment.apps/istio-citadel created
deployment.apps/istio-galley created
deployment.apps/istio-pilot created
deployment.apps/istio-policy created
deployment.apps/istio-sidecar-injector created
deployment.apps/istio-telemetry created
deployment.apps/prometheus created
poddisruptionbudget.policy/istio-galley created
poddisruptionbudget.policy/istio-pilot created
poddisruptionbudget.policy/istio-policy created
poddisruptionbudget.policy/istio-sidecar-injector created
poddisruptionbudget.policy/istio-telemetry created
horizontalpodautoscaler.autoscaling/istio-pilot created
horizontalpodautoscaler.autoscaling/istio-policy created
horizontalpodautoscaler.autoscaling/istio-telemetry created
job.batch/istio-security-post-install-1.3.4 created
attributemanifest.config.istio.io/istioproxy created
attributemanifest.config.istio.io/kubernetes created
handler.config.istio.io/kubernetesenv created
handler.config.istio.io/prometheus created
instance.config.istio.io/attributes created
instance.config.istio.io/requestcount created
instance.config.istio.io/requestduration created
instance.config.istio.io/requestsize created
instance.config.istio.io/responsesize created
instance.config.istio.io/tcpbytereceived created
instance.config.istio.io/tcpbytesent created
instance.config.istio.io/tcpconnectionsclosed created
instance.config.istio.io/tcpconnectionsopened created
rule.config.istio.io/kubeattrgenrulerule created
rule.config.istio.io/promhttp created
rule.config.istio.io/promtcpconnectionclosed created
rule.config.istio.io/promtcpconnectionopen created
rule.config.istio.io/promtcp created
rule.config.istio.io/tcpkubeattrgenrulerule created
destinationrule.networking.istio.io/istio-policy created
destinationrule.networking.istio.io/istio-telemetry created
sleep 8
kubectl apply -k ./helloworld
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created
ingress.extensions/helloworld created
((curl --silent -v -k -i http://fou.test/hello | grep '200 OK') && echo "HELLO WORLD for Istio  PASSED") || echo "HELLO WORLD for Istio  FAILED"
*   Trying 127.0.0.1:80...
* TCP_NODELAY set
* Connected to fou.test (127.0.0.1) port 80 (#0)
> GET /hello HTTP/1.1
> Host: fou.test
> User-Agent: curl/7.65.3
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 404 Not Found
< Server: openresty/1.15.8.2
< Date: Tue, 05 Nov 2019 08:58:41 GMT
< Content-Type: text/html
< Content-Length: 159
< Connection: keep-alive
<
{ [159 bytes data]
* Connection #0 to host fou.test left intact
HELLO WORLD for Istio  FAILED
sleep 10
((curl --silent -v -k -i http://fou.test/hello | grep '200 OK') && echo "HELLO WORLD for Istio  PASSED") || echo "HELLO WORLD for Istio  FAILED"
*   Trying 127.0.0.1:80...
* TCP_NODELAY set
* Connected to fou.test (127.0.0.1) port 80 (#0)
> GET /hello HTTP/1.1
> Host: fou.test
> User-Agent: curl/7.65.3
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 503 Service Temporarily Unavailable
< Server: openresty/1.15.8.2
< Date: Tue, 05 Nov 2019 08:58:52 GMT
< Content-Type: text/html
< Content-Length: 203
< Connection: keep-alive
<
{ [203 bytes data]
* Connection #0 to host fou.test left intact
HELLO WORLD for Istio  FAILED
sleep 10
((curl --silent -v -k -i http://fou.test/hello | grep '200 OK') && echo "HELLO WORLD for Istio  PASSED") || echo "HELLO WORLD for Istio  FAILED"
*   Trying 127.0.0.1:80...
* TCP_NODELAY set
* Connected to fou.test (127.0.0.1) port 80 (#0)
> GET /hello HTTP/1.1
> Host: fou.test
> User-Agent: curl/7.65.3
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 503 Service Temporarily Unavailable
< Server: openresty/1.15.8.2
< Date: Tue, 05 Nov 2019 08:59:02 GMT
< Content-Type: text/html
< Content-Length: 203
< Connection: keep-alive
<
{ [203 bytes data]
* Connection #0 to host fou.test left intact
HELLO WORLD for Istio  FAILED
sleep 10
((curl --silent -v -k -i http://fou.test/hello | grep '200 OK') && echo "HELLO WORLD for Istio  PASSED") || echo "HELLO WORLD for Istio  FAILED"
*   Trying 127.0.0.1:80...
* TCP_NODELAY set
* Connected to fou.test (127.0.0.1) port 80 (#0)
> GET /hello HTTP/1.1
> Host: fou.test
> User-Agent: curl/7.65.3
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 503 Service Temporarily Unavailable
< Server: openresty/1.15.8.2
< Date: Tue, 05 Nov 2019 08:59:12 GMT
< Content-Type: text/html
< Content-Length: 203
< Connection: keep-alive
<
{ [203 bytes data]
* Connection #0 to host fou.test left intact
HELLO WORLD for Istio  FAILED
sleep 10
((curl --silent -v -k -i http://fou.test/hello | grep '200 OK') && echo "HELLO WORLD for Istio  PASSED") || echo "HELLO WORLD for Istio  FAILED"
*   Trying 127.0.0.1:80...
* TCP_NODELAY set
* Connected to fou.test (127.0.0.1) port 80 (#0)
> GET /hello HTTP/1.1
> Host: fou.test
> User-Agent: curl/7.65.3
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 503 Service Temporarily Unavailable
< Server: openresty/1.15.8.2
< Date: Tue, 05 Nov 2019 08:59:22 GMT
< Content-Type: text/html
< Content-Length: 203
< Connection: keep-alive
<
{ [203 bytes data]
* Connection #0 to host fou.test left intact
HELLO WORLD for Istio  FAILED
sleep 10
((curl --silent -v -k -i http://fou.test/hello | grep '200 OK') && echo "HELLO WORLD for Istio  PASSED") || echo "HELLO WORLD for Istio  FAILED"
*   Trying 127.0.0.1:80...
* TCP_NODELAY set
* Connected to fou.test (127.0.0.1) port 80 (#0)
> GET /hello HTTP/1.1
> Host: fou.test
> User-Agent: curl/7.65.3
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 503 Service Temporarily Unavailable
< Server: openresty/1.15.8.2
< Date: Tue, 05 Nov 2019 08:59:32 GMT
< Content-Type: text/html
< Content-Length: 203
< Connection: keep-alive
<
{ [203 bytes data]
* Connection #0 to host fou.test left intact
HELLO WORLD for Istio  FAILED

h@LT-4SQZY2 MINGW64 /c/dev/istio-bugs (master)
$ make test
((curl --silent -v -k -i http://fou.test/hello | grep '200 OK') && echo "HELLO WORLD for Istio  PASSED") || echo "HELLO WORLD for Istio  FAILED"
*   Trying 127.0.0.1:80...
* TCP_NODELAY set
* Connected to fou.test (127.0.0.1) port 80 (#0)
> GET /hello HTTP/1.1
> Host: fou.test
> User-Agent: curl/7.65.3
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 502 Bad Gateway
< Server: openresty/1.15.8.2
< Date: Tue, 05 Nov 2019 09:01:27 GMT
< Content-Type: text/html
< Content-Length: 163
< Connection: keep-alive
<
{ [163 bytes data]
* Connection #0 to host fou.test left intact
HELLO WORLD for Istio  FAILED
sleep 10
((curl --silent -v -k -i http://fou.test/hello | grep '200 OK') && echo "HELLO WORLD for Istio  PASSED") || echo "HELLO WORLD for Istio  FAILED"
*   Trying 127.0.0.1:80...
* TCP_NODELAY set
* Connected to fou.test (127.0.0.1) port 80 (#0)
> GET /hello HTTP/1.1
> Host: fou.test
> User-Agent: curl/7.65.3
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 502 Bad Gateway
< Server: openresty/1.15.8.2
< Date: Tue, 05 Nov 2019 09:01:37 GMT
< Content-Type: text/html
< Content-Length: 163
< Connection: keep-alive
<
{ [163 bytes data]
* Connection #0 to host fou.test left intact
HELLO WORLD for Istio  FAILED
sleep 10
make: *** [Makefile:96: test] Error 512


```