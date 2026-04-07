# Use official Node.js 20 lightweight Alpine Linux image
# Alpine = very small size (~5MB vs ~900MB for full Ubuntu)
FROM node:20-alpine

# Set working directory inside container
# All following commands run from this folder
WORKDIR /app

# Copy package.json first (before rest of code)
# This is a Docker best practice — allows layer caching
# If package.json hasn't changed, npm install won't re-run
COPY package.json .
COPY package-lock.json .

# Install exact versions from package-lock.json
# --legacy-peer-deps = ignore peer dependency version conflicts
RUN npm ci --legacy-peer-deps

# Copy ALL remaining project files into the container
# (Done AFTER npm install to use Docker layer cache)
COPY . .

# Build the React app using Vite
# Creates a /dist folder with production-ready files
RUN npm run build

# Tell Docker this container listens on port 4173
# (Vite preview server default port)
EXPOSE 4173

# Start the Vite preview server when container runs
# --host 0.0.0.0 = listen on ALL network interfaces
# (without this, app only accessible inside container!)
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0"]