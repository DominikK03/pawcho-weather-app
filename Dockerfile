FROM node:20-alpine AS build

LABEL org.opencontainers.image.authors="Dominik Kępczyk"
LABEL org.opencontainers.image.description="Weather App - CI/CD Pipeline Docker Image"

WORKDIR /var/www
COPY package*.json ./
RUN npm install --production --ignore-scripts && npm cache clean --force
COPY . .

FROM alpine:latest AS run
WORKDIR /var/www

RUN apk --no-cache add nodejs &&\
    rm -rf /var/cache/apk/*

COPY --from=build /var/www/ ./

ENV NODE_ENV=production \
 PORT=3000

HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:3000/ || exit 1

EXPOSE 3000
CMD ["npm", "start"]