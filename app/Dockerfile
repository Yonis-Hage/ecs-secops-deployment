FROM node:18-alpine AS build

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install

COPY . .
RUN yarn build


FROM node:18-alpine

WORKDIR /app


RUN addgroup -S nonroot && adduser -S nonroot -G nonroot


COPY --from=build /app/build ./build

COPY package.json yarn.lock ./

RUN yarn install --production

USER nonroot:nonroot

EXPOSE 3000

CMD ["npx", "serve", "-s", "build", "-l", "3000"]
