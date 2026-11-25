# [Ollama](https://ollama.com)

### Version

```bash
k exec -n ollama -it <NODE_NAME> -- ollama -v
```

Results

```
ollama version is 0.40.15
```

### Status

```bash
k exec -n ollama -it <NODE_NAME> -- ollama ps
```

Results

```bash
NAME          ID              SIZE      PROCESSOR    CONTEXT    RUNNER      UNTIL
qwen3.5:4b    d8b0f5e9760c    4.7 GB    100% CPU     65536      llamacpp    Forever
```

### List

```bash
k exec -n ollama -it <NODE_NAME> -- ollama list
```

Results

```
NAME                ID              SIZE      MODIFIED
llama3.2:latest     a80c4f17acd5    2.0 GB    6 minutes ago
qwen3.5:4b          d8b0f5e9760c    3.3 GB    7 days ago
qwen2.5-coder:3b    f72c60cabf62    1.9 GB    7 days ago
qwen2.5-coder:7b    dae161e27b0e    4.7 GB    7 days ago
```

### Pull a model

```bash
k exec -n ollama -it <NODE_NAME> -- ollama pull MODEL_NAME
```

### Remove model

```bash
k exec -n ollama -it <NODE_NAME> -- ollama rm qwen3.5
```

### Access

Verify Ollama is running with curl. The service exposes port 31434 via:

```bash
curl http://localhost:31434
# or
curl http://jessica:31434
# or
curl http://192.168.10.56:31434
# or
curl http://ollama.jessica.com/
```

All should return: `Ollama is running`
