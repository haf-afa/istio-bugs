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