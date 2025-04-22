# Podman Summary

Podman (Pod Manager) is an open-source, **daemonless** container engine for developing, managing, and running OCI-compliant containers and container images, primarily on Linux systems. It is often positioned as a direct alternative to Docker.

## Key Features & Differences from Docker

* **Architecture:** Podman operates **daemonless**, meaning commands interact directly with the Linux kernel, storage, and registries without needing a persistent background daemon like Docker's `dockerd`. This can improve robustness (no single point of failure) and reduce resource overhead.
* **Security (Rootless Focus):** A major differentiator is Podman's ability to run **rootless** by default. Unprivileged users can build, run, and manage containers securely within their own user space, significantly reducing the security risks associated with root-running daemons.
* **CLI Compatibility:** Podman aims for high compatibility with the Docker command-line interface. Often, users can simply use `alias docker=podman` and run familiar commands.
* **Native Pod Support:** Podman treats Kubernetes-style **Pods** (groups of containers sharing network and other namespaces) as first-class objects, making it easy to manage related containers together.
* **Ecosystem Integration:** Often used alongside related tools like **Buildah** (for specialized image building) and **Skopeo** (for moving/inspecting images between registries and storage). It has strong backing from Red Hat and is the default container engine on RHEL, Fedora, and CentOS Stream.
* **Compose Support:** Podman doesn't have a built-in `compose` command. Multi-container orchestration typically uses:
    * `podman-compose` (a separate community tool).
    * The official `docker compose` tool configured to use the Podman API socket.
* **Kubernetes Integration:** Podman includes commands like `podman kube play` (to run applications defined in Kubernetes YAML) and `podman kube generate` (to create Kubernetes YAML from Podman pods/containers), facilitating workflows aligned with Kubernetes.
* **GUI Tool:** **Podman Desktop** is available as an open-source graphical interface alternative to Docker Desktop, providing UI-based management for containers, images, pods, and registries.

## Platform Support

* **Linux:** Runs natively and is well-integrated, especially with systemd.
* **macOS & Windows:** Podman is available and provides a native CLI experience. However, it runs containers within a background **Linux virtual machine** managed via `podman machine` (using QEMU on Mac, WSL 2 on Windows).
* **Windows Containers:** Podman **does not** support running or building native **Windows containers**. It manages *Linux* containers, even when run from a Windows host.

## Use Cases

Podman is often preferred by users who:
* Prioritize security (especially the rootless capability).
* Prefer a daemonless architecture.
* Work primarily in Linux environments (particularly RHEL-based).
* Want native pod management similar to Kubernetes.
* Prefer open-source tooling like Podman Desktop.

In essence, Podman offers a Docker-compatible experience with a strong focus on security through its daemonless and rootless design, while also integrating well with Linux system tools and Kubernetes concepts.