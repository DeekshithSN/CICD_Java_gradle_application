---
apiVersion: v1
kind: Service
metadata:
  name: myapp
  labels:
    helm.sh/chart: myapp-0.2.0
    app.kubernetes.io/name: myapp
    app.kubernetes.io/instance: myapp
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
spec:
  type: NodePort
  ports:
    - port: 8080
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: myapp
    app.kubernetes.io/instance: myapp
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    helm.sh/chart: myapp-0.2.0
    app.kubernetes.io/name: myapp
    app.kubernetes.io/instance: myapp
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: myapp
      app.kubernetes.io/instance: myapp
  template:
    metadata:
      labels:
        app.kubernetes.io/name: myapp
        app.kubernetes.io/instance: myapp
    spec:
      imagePullSecrets:
        - name: registry-secret
      containers:
        - name: myapp
          image: imagename
          command: ["/bin/sh"]
          args: ["-c","sh /usr/local/tomcat/bin/startup.sh;while true; do echo hello; sleep 10;done"]
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 60
            periodSeconds: 5
            successThreshold: 1
            failureThreshold: 3
            timeoutSeconds: 10
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 60
            periodSeconds: 5
            successThreshold: 1
            failureThreshold: 3
            timeoutSeconds: 10
          resources:
            requests:
              memory: 0.25Gi
              cpu: 0.5
            limits:
              memory: 0.25Gi 
              cpu: 0.5
