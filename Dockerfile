# Use Node.js as a base image
FROM node:20-alpine as build

# Set the working directory inside the container
WORKDIR /app

# Install Bun
RUN apk add curl \
    && curl -fsSL https://bun.sh/install | bash \
    && mv /root/.bun/bin/bun /usr/local/bin/bun

# Add Bun to the PATH
ENV PATH="/usr/local/bin:$PATH"

# Copy package.json and lockfile for installation
COPY package.json ./
COPY bun.lockb ./

# Install dependencies using Bun with caching
RUN --mount=type=cache,id=bun,target=/root/.bun bun install --frozen-lockfile

# Define build arguments
ARG PWA_ENABLED="true"
ARG GA_ID
ARG APP_DOMAIN
ARG OPENSEARCH_ENABLED="false"
ARG TMDB_READ_API_KEY
ARG CORS_PROXY_URL
ARG DMCA_EMAIL
ARG NORMAL_ROUTER="false"
ARG BACKEND_URL
ARG HAS_ONBOARDING="false"
ARG ONBOARDING_CHROME_EXTENSION_INSTALL_LINK
ARG ONBOARDING_PROXY_INSTALL_LINK
ARG DISALLOWED_IDS
ARG CDN_REPLACEMENTS
ARG TURNSTILE_KEY
ARG ALLOW_AUTOPLAY="false"

# Set environment variables
ENV VITE_PWA_ENABLED=${PWA_ENABLED}
ENV VITE_GA_ID=${GA_ID}
ENV VITE_APP_DOMAIN=${APP_DOMAIN}
ENV VITE_OPENSEARCH_ENABLED=${OPENSEARCH_ENABLED}
ENV VITE_TMDB_READ_API_KEY=${TMDB_READ_API_KEY}
ENV VITE_CORS_PROXY_URL=${CORS_PROXY_URL}
ENV VITE_DMCA_EMAIL=${DMCA_EMAIL}
ENV VITE_NORMAL_ROUTER=${NORMAL_ROUTER}
ENV VITE_BACKEND_URL=${BACKEND_URL}
ENV VITE_HAS_ONBOARDING=${HAS_ONBOARDING}
ENV VITE_ONBOARDING_CHROME_EXTENSION_INSTALL_LINK=${ONBOARDING_CHROME_EXTENSION_INSTALL_LINK}
ENV VITE_ONBOARDING_PROXY_INSTALL_LINK=${ONBOARDING_PROXY_INSTALL_LINK}
ENV VITE_DISALLOWED_IDS=${DISALLOWED_IDS}
ENV VITE_CDN_REPLACEMENTS=${CDN_REPLACEMENTS}
ENV VITE_TURNSTILE_KEY=${TURNSTILE_KEY}
ENV VITE_ALLOW_AUTOPLAY=${ALLOW_AUTOPLAY}

# Copy all source code
COPY . ./

# Run the build using Bun
RUN bun run build

# Production environment
FROM nginx:stable-alpine

# Copy built files from the build stage to the Nginx container
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80 for the application
EXPOSE 80

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
