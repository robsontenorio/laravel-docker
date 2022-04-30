FROM robsontenorio/laravel:octane as base
COPY --chown=appuser:appuser . .

# Locally will run this stage ONLY (see docker-compose.yml > build > target)
FROM base as local
CMD ["/usr/local/bin/start"] 

# Set this stage when building for production 
FROM base as production
RUN chmod a+x .docker/deploy.sh
CMD ["/bin/sh", "-c", ".docker/deploy.sh && /usr/local/bin/start"] 

