# ---------- Build (Node) ----------
FROM node:22-bookworm-slim AS build
WORKDIR /app
ENV CI=true
RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ \
  && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci --include=dev

COPY . .
# 👉 adapte si ton script n'est pas "build"
RUN npm run build

# ---------- Runtime (Nginx) ----------
FROM nginx:alpine
# Remplace la conf par la nôtre
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copie le build (Vite = dist ; CRA = build ; Next export = out)
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
