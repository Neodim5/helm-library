# Helm Library Chart - App

Production-ready Helm library chart for deploying applications to Kubernetes.

## Features

- **Deployment-first design** with optional features via feature flags
- **Multi-registry support** for dev/prod registry separation
- **Health probes abstraction** (HTTP/TCP)
- **Ingress support** (Traefik, Nginx, or any ingress controller)
- **ConfigMap and Secret management**
- **Security contexts** (runAsNonRoot, readOnlyRootFilesystem)
- **Scheduling controls** (nodeSelector, tolerations, affinity)
- **Schema validation** for values.yaml
- **Unit tests** with helm-unittest
- **Manifest validation** with kubeconform

## Structure

```
helm-library/
├── charts/
│   └── app/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values.schema.json
│       ├── tests/
│       │   ├── deployment_test.yaml
│       │   ├── service_test.yaml
│       │   ├── ingress_test.yaml
│       │   └── configmap_secret_test.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── deployment.tpl
│           ├── service.tpl
│           ├── ingress.tpl
│           ├── configmap.tpl
│           └── secret.tpl
├── .gitlab-ci.yml
└── README.md
```

## Usage

### As a Library Chart

In your service's `Chart.yaml`:

```yaml
dependencies:
  - name: app
    version: 1.0.0
    repository: oci://registry.gitlab.com/your-group/helm-library
```

In your service's templates:

```yaml
# deployment.yaml
{{ include "app.deployment" . }}

# service.yaml
{{ include "app.service" . }}

# ingress.yaml
{{ include "app.ingress" . }}

# configmap.yaml
{{ include "app.configmap" . }}

# secret.yaml
{{ include "app.secret" . }}
```

### Values Example

```yaml
image:
  registry: registry.example.com
  repository: my-app
  tag: "v1.0.0"
  pullPolicy: IfNotPresent
  pullSecrets:
    - regcred

deployment:
  replicas: 3
  strategy:
    type: RollingUpdate

service:
  enabled: true
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: traefik
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    enabled: true
    secretName: myapp-tls

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

probes:
  enabled: true
  liveness:
    type: http
    path: /health
    port: 8080
  readiness:
    type: http
    path: /ready
    port: 8080

env:
  plain:
    LOG_LEVEL: info
  configMap:
    DATABASE_URL: postgres://db:5432
  secret:
    API_KEY: supersecret

security:
  runAsNonRoot: true
  readOnlyRootFilesystem: true
```

## Development

### Install Dependencies

```bash
# Install helm-unittest plugin
helm plugin install https://github.com/helm-unittest/helm-unittest.git

# Install kubeconform (for validation)
# macOS
brew install kubeconform
# Linux
wget https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz
tar xzf kubeconform-linux-amd64.tar.gz
sudo mv kubeconform /usr/local/bin/
```

### Run Tests

```bash
# Lint
helm lint charts/app

# Unit tests
helm unittest charts/app

# Validate manifests
helm template test charts/app | kubeconform -strict -ignore-missing-schemas
```

### Package and Publish

```bash
# Package
helm package charts/app

# Push to OCI registry
helm push app-*.tgz oci://registry.gitlab.com/your-group/helm-library
```

## Versioning Policy

This chart follows Semantic Versioning:

- **PATCH (1.0.x)**: Bug fixes, default value changes, optional fields added
- **MINOR (1.x.0)**: New features, optional blocks added
- **MAJOR (x.0.0)**: Breaking changes, field removals, structure changes

### Backward Compatibility

- Fields are never removed, only deprecated
- New features are optional and disabled by default
- Schema changes follow the versioning policy above

## CI/CD Pipeline

The `.gitlab-ci.yml` includes:

1. **Lint**: Validate chart structure
2. **Test**: Run unit tests
3. **Validate**: Check rendered manifests with kubeconform
4. **Package**: Create chart archive (on tags/main)
5. **Publish**: Push to OCI registry (on tags only)

## Migration Guide

### From Manual Charts

1. Add library chart as dependency
2. Replace your templates with `include` statements
3. Map your values to the new schema
4. Test with `helm template` before deploying

### Upgrading Library Chart

1. Review changelog for breaking changes
2. Update dependency version in Chart.yaml
3. Run `helm lint` and `helm unittest`
4. Test in non-production environment first

## Troubleshooting

### Schema Validation Errors

```bash
# Check values against schema
helm lint charts/app --values values.yaml
```

### Template Rendering Issues

```bash
# Debug template rendering
helm template debug charts/app --debug
```

### Test Failures

```bash
# Run tests with verbose output
helm unittest charts/app --verbose
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Ensure all tests pass
5. Submit a merge request

## License

MIT
