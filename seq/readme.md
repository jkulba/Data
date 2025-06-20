# Create SEQ pod

To create a pod with the seq logging server, follow these steps:

## (1) Create a pod

Create a new pod with the seq default ports and name it `seqpod`.

```shell
podman pod create --name seqpod -p 5341:5341
```
This creates a pod named seqpod and maps port 5341 (Seq default) from the pod to your host.
