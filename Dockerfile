# define from what image we want to build from
FROM node:14.16

# specifies the port in which an application is listening
ENV PORT=8000

# specifies the environment in which an application is running, here "development" environment
ENV NODE_ENV=development

# we create a directory to hold the application code inside the image
WORKDIR /app

## install app dependencies using npm
# copy package.json AND package-lock.json in the created  /app directory
COPY package*.json ./

# install npm
RUN npm install

# bundle app source: copy the directory /projet-groupe-1(except the files/folder of .dockerignore) in  /app directory; 
COPY . .

# informs Docker that the container listens on this port at runtime
EXPOSE 8000

#define the command to run the app: here we use node server.js to start our server
CMD [ "npm", "start" ]