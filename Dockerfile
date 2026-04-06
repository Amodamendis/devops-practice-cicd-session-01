# 1. Use the optimized Node 20 Alpine image we identified earlier
FROM node:20-alpine

# 2. Set the working directory inside the container (just like your screenshot)
WORKDIR /app

# 3. Copy ONLY the package files first
COPY package.json .
COPY package-lock.json .

# 4. Install your project dependencies
RUN npm ci --legacy-peer-deps

# 5. Copy the rest of your project files into the container
COPY . .

# 6. Build the React app (creates the /dist folder)
RUN npm run build

# 7. Expose the port that Vite uses for its preview server
EXPOSE 4173

# 8. Start the app (Unlike 'node app.js', Vite needs to serve the built files)
CMD ["npm", "run", "preview", "--", "--host"]