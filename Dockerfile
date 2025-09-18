FROM node:7.8.0

ARG PORT=3000
ARG BRANCH=main

ENV PORT=${PORT}
ENV BRANCH=${BRANCH}

WORKDIR /opt
ADD . /opt
RUN npm install

EXPOSE ${PORT}

CMD ["sh", "-c", "npm start -- --port ${PORT}"]
