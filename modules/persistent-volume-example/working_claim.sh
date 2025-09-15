microk8s kubectl apply -f - <<EOF
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgresql-pv
spec:
  storageClassName: "pstore-high"
  persistentVolumeReclaimPolicy: Retain
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/shares/data/postgresql"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-pvc
spec:
  storageClassName: "pstore-high"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: postgresql-nginx
spec:
  volumes:
    - name: pvc
      persistentVolumeClaim:
        claimName: postgresql-pvc
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
      volumeMounts:
        - name: pvc
          mountPath: /usr/share/nginx/html
EOF
