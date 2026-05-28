.PHONY: build run docker-build docker-build-db argocd-deploy db-init clean

ECR_REPO = 293222827824.dkr.ecr.us-east-1.amazonaws.com/roboshop-user

build:
	npm install

run:
	MONGO_URL=mongodb://localhost:27017/users node server.js

docker-build:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 293222827824.dkr.ecr.us-east-1.amazonaws.com
	docker build -t $(ECR_REPO):$(image_tag) .
	trivy image $(ECR_REPO):$(image_tag) -s CRITICAL,HIGH --ignore-unfixed
	docker push $(ECR_REPO):$(image_tag)

docker-build-db:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 293222827824.dkr.ecr.us-east-1.amazonaws.com
	docker build -t $(ECR_REPO)-db:latest ./db
	trivy image $(ECR_REPO)-db:latest -s CRITICAL,HIGH --ignore-unfixed
	docker push $(ECR_REPO)-db:latest

argocd-deploy:
	argocd login $(argocd_server) --skip-test-tls --username admin --password $(argocd_admin_password)
	argocd app create roboshop-user --sync-policy auto --upsert \
		--repo https://github.com/nikkaushal/roboshop-helm-v1.git \
		--path . \
		--dest-server https://kubernetes.default.svc \
		--dest-namespace roboshop \
		--helm-set services.user.tag=$(image_tag) \
		--values values/roboshop-user.yml

db-init:
	mongosh --host $${MONGO_HOST:-localhost} < db/master-data.js

clean:
	rm -rf node_modules
