# Build Image
# FIXME: image name should be changed to the correct one
FROM node:20 AS build
# WORKDIR /app
COPY . .
RUN echo "Building the app"


# Product Image
# FIXME: image name should be changed to the correct one
FROM public.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-nginx:latest-al23

USER root
RUN <<EOF
echo "Installing app"
echo "Done"
EOF

# COPY --from=build /app/build /usr/share/nginx/html

# EXPOSE 8080
# USER nginx
# CMD ["nginx", "-g", "daemon off;"]
