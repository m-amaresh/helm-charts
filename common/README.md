# Common Library Chart

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
![Type: Library](https://img.shields.io/badge/Type-Library-informational)

A Helm library chart providing reusable templates and utilities for Kubernetes applications inspired and adopted from Bitnami.

## 📋 Overview

This library chart contains common templates that can be shared across multiple charts in this repository. It follows Helm library chart patterns and provides standardized, reusable components.

## 🧩 Available Helpers

### Core Components
- **Names & Labels**: Standardized naming and labeling patterns
- **Template Rendering**: Safe template value rendering utilities
- **API Capabilities**: Kubernetes version compatibility helpers

### Security
- **Pod Security Context**: Compliant with Pod Security Standards
- **Container Security Context**: Secure container configurations
- **Non-root execution**, **read-only filesystems**, **dropped capabilities**

### Resources
- **Resource Presets**: Pre-configured resource sizing
  - `nano`, `micro`, `small`, `medium`, `large`, `xlarge`, `2xlarge`
- **Custom Resources**: Support for custom resource specifications

### Storage & Images
- **Storage Classes**: Persistent volume configuration helpers
- **Image Handling**: Global registry override support

## 🚀 Usage

### In Chart.yaml
```yaml
dependencies:
  - name: common
    version: "1.0.0"
    repository: "oci://ghcr.io/m-amaresh"
```

### In Templates
```yaml
# Names and labels
metadata:
  name: {{ include "common.names.fullname" . }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}

# Security contexts
spec:
  securityContext: {{- include "common.security.podSecurityContext" (dict "securityContext" .Values.podSecurityContext "context" .) | nindent 4 }}

# Resource presets
resources: {{- include "common.resources.preset" (dict "type" .Values.resourcesPreset) | nindent 2 }}

# Template rendering
{{- include "common.tplvalues.render" (dict "value" .Values.customConfig "context" $) | nindent 2 }}
```

## 📝 Design Philosophy

This library chart follows the principle of **minimal, truly reusable components**:

✅ **Included**: Generic Kubernetes patterns that any chart can use  
❌ **Excluded**: Application-specific logic that belongs in individual charts

This ensures that any new chart can use this library without modification.

## 🔄 Version Compatibility

- **Kubernetes**: 1.31+
- **Helm**: 3.0+

## 📄 License

Licensed under the Apache License, Version 2.0.
