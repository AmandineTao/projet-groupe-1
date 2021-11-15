FROM node:14.16
ENV PORT=8000
ENV NODE_ENV=development

#create app directory
WORKDIR /app

COPY package*.json ./
RUN npm install

#bundle app source
COPY . .
EXPOSE 8000
CMD [ "npm", "start" ]