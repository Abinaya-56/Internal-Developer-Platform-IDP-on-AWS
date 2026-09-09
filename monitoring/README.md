# Monitoring

The platform ships a `ServiceMonitor` (in the Helm chart, enabled via
`metrics.enabled: true` — already on for the `stage` environment) that
exposes nginx request metrics to Prometheus.

## Install the monitoring stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f monitoring/kube-prometheus-stack-values.yaml
```

This installs Prometheus, Grafana, and the Prometheus Operator (which
provides the `ServiceMonitor` CRD the app's Helm chart relies on).

## Access Grafana

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

Open `http://localhost:3000` — default login is `admin` / `admin` (set in
`kube-prometheus-stack-values.yaml`; change it before using this anywhere
beyond a local demo).

## Verify the app's metrics are being scraped

```bash
kubectl get servicemonitor -n stage
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```

Open `http://localhost:9090/targets` and confirm `idp-demo` shows as `UP`.

## Notes

- `metrics.enabled` is off by default in `dev` and on in `stage` — see
  `infra/helm/idp-demo/values-dev.yaml` / `values-stage.yaml`. Flip it on
  for `dev` too with `--set metrics.enabled=true` if you want it there.
- The exporter scrapes nginx's built-in `/stub_status` endpoint (enabled in
  `apps/demo-app/nginx.conf`), so it only reports connection/request counts,
  not application-level metrics — good enough for demo purposes, not a
  substitute for real app instrumentation.
