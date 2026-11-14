# [Ollama](https://ollama.com)

### Version

```
k exec -n ollama -it pod/ollama-deployment-869c8cc9c-h955f -- ollama -v
```

Results

```
ollama version is 0.40.15
```

### Status

```
k exec -n ollama -it pod/ollama-deployment-869c8cc9c-h955f -- ollama ps
```

Results

```
NAME          ID              SIZE      PROCESSOR    CONTEXT    RUNNER      UNTIL
qwen3.5:4b    d8b0f5e9760c    4.7 GB    100% CPU     65536      llamacpp    Forever
```

### List

```
k exec -n ollama -it pod/ollama-deployment-869c8cc9c-h955f -- ollama list
```

Results

```
NAME                ID              SIZE      MODIFIED
llama3.2:latest     a80c4f17acd5    2.0 GB    6 minutes ago
qwen3.5:4b          d8b0f5e9760c    3.3 GB    7 days ago
qwen2.5-coder:3b    f72c60cabf62    1.9 GB    7 days ago
qwen2.5-coder:7b    dae161e27b0e    4.7 GB    7 days ago
```
