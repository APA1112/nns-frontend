# Etapa 1: Construcción
FROM node:22-slim AS build
WORKDIR /app

# Copiamos archivos de dependencias
COPY package*.json ./

# Instalamos con flags para evitar conflictos con React 19
RUN npm install --legacy-peer-deps

# Copiamos el resto del código y construimos
COPY . .
RUN npm run build

# Etapa 2: Servidor de producción (Nginx)
FROM nginx:stable-alpine
# Copiamos el resultado de Vite (carpeta dist) al directorio de Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Configuración básica para SPA (React Router soporte)
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]