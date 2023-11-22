# Nginx Example

### Add `index.html`

As mentioned in the variable file, `host_data_directory` will point to the data directory. Create the index file there, `html\index.html`.

### Connect

```
% kubectl exec -n npm -it pod/<pod_name> -- /bin/bash
```
