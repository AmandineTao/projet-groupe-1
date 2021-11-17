#test commit
FROM node:14.16
ENV PORT=8000
ENV NODE_ENV=development
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8000
CMD [ "npm", "start" ]