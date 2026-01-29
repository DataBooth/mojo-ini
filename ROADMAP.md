# mojo-ini Roadmap

## Package Distribution

### Cannot Use `noarch: generic`
**Status:** Not applicable

mojo-ini builds a compiled `.mojopkg` file during installation:
```yaml
build:
  script:
    - mojo package src/ini -o ${PREFIX}/lib/mojo/ini.mojopkg
```

**Reason:** `.mojopkg` files are platform-specific binaries  
**Impact:** Package must build separately per platform (Linux, macOS, ARM64)

**Alternative:** Continue with current multi-platform build approach

See [docs/PLATFORM_BUILDS.md](docs/PLATFORM_BUILDS.md#noarch-packages) for explanation.

---

## Feature Roadmap

Tracked in main [README.md](README.md):
- Enhanced INI syntax support
- Performance improvements
- Additional configparser compatibility

---

## Maintenance

### Recipe Validation
✅ **Completed (2026-01-29)**
- Local validation with rattler-build
- GitHub Actions automation  
- Pre-commit hook integration

### Mojo Version Management
✅ **Completed (2026-01-29)**
- Standardized to `mojo_version: "=0.25.7"` context variable

---

**Last updated:** 2026-01-29
