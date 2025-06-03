FROM node:20-alpine AS build

WORKDIR /var/www
COPY package*.json ./
RUN npm install --production --ignore-scripts && npm cache clean --force
COPY bin ./bin/
COPY public public/
COPY routes routes/
COPY views views/
COPY app.js config.js ./

FROM alpine:latest AS run
WORKDIR /var/www

LABEL org.opencontainers.image.authors="Dominik Kępczyk"
LABEL org.opencontainers.image.description="Weather App - CI/CD Pipeline Docker Image"

RUN apk --no-cache add --virtual .runtime-deps nodejs &&\
    rm -rf /var/cache/apk/*

COPY --from=build /var/www/ ./

ENV NODE_ENV=production \
 PORT=3000

HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:3000/ || exit 1

EXPOSE 3000
CMD ["./bin/www"]