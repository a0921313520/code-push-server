FROM node:12.18.3-alpine

RUN npm i -g code-push-server@5.7.1 pm2@latest --no-optional

COPY ./security.js /usr/local/lib/node_modules/code-push-server/core/utils/security.js
COPY ./package-manager.js /usr/local/lib/node_modules/code-push-server/core/services/package-manager.js
COPY ./process.json /process.json

EXPOSE 3000

CMD ["pm2-docker", "start", "/process.json"]
