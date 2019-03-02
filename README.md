# docker-laravel

A script for building Dockerfile and docker-compose.yml based on Laravel project requirements.

## Usage

Checkout the repository:

    git clone https://github.com/datashaman/docker-laravel.git
    cd docker-laravel

Generate _Dockerfile_ and _docker-compose.yml_ with:

    ./build.sh php7.2 memcached mariadb elasticsearch redis

Move Dockerfile and docker-compose.yml into your project folder.

Edit your current _.env_ file and remove any references to hostnames of services you've just added.

For example, `DB_HOST`, `ELASTICSEARCH_HOST`, `MEMCACHED_HOST`, `REDIS_HOST`. These will be configured inside the Compose stack.

Bring the Compose stack up:

    docker-compose up

Once it's pulled and built everything see which ports are open:

    docker-compose ports

Open the [site](http://127.0.0.1).
