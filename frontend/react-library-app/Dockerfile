# Build Vite app
FROM node:18 AS build
WORKDIR /app

# Install deps (cached if package.json/lock unchanged)
COPY package*.json ./
RUN npm install

# Copy the rest of the source and build
COPY . .
RUN npm run build

# Nginx stage
FROM nginx:alpine

# Copy built files
COPY --from=build /app/dist /usr/share/nginx/html

# Optional: custom nginx.conf (important for React Router / SPA)
COPY nginx.conf /etc/nginx/conf.d/default.conf
