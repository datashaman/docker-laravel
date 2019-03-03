# docker-laravel

A script for building Dockerfile and docker-compose.yml based on Laravel project requirements.

## Usage

Checkout the repository:

    git clone https://github.com/datashaman/docker-laravel.git
    cd docker-laravel

Generate _Dockerfile_ and _docker-compose.yml_ with:

    ./build.sh php7.2 beanstalkd mailhog memcached mariadb elasticsearch redis

Move Dockerfile and docker-compose.yml into your project folder.

Edit your current _.env_ file and remove any references to hostnames of services you've just added.

For example, `DB_HOST`, `ELASTICSEARCH_HOST`, `MEMCACHED_HOST`, `REDIS_HOST`. These will be configured inside the Compose stack.

Bring the Compose stack up:

    docker-compose up

Once it's pulled and built everything see which ports are open:

    docker-compose ps

The stack exposes the following HTTP endpoints:

- [beanstalkd console](http://127.0.0.1:2080)
- [mailhog](http://127.0.0.1:8025)
- [web app](http://127.0.0.1:8080)
- [redis commander](http://127.0.0.1:8081)

The _app_ uses the _PHP-FPM_ binary, but can also be used for CLI usage. Do something like this to run your migrations and setup up your instance's data:

- docker-compose run app composer install
- docker-compose run app php artisan migrate --seed

Typing that all the time is a _PITA_, so setup an alias in your _.bashrc_ or similar:

    alias dl='docker-compose run app'

And use it like this:

    dl composer install
    dl php artisan migrate --seed

Services available in the stack:

- _app_ running workspace code
- _beanstalkd_
- _beanstalkd-console_
- _db_ running mysql, mariadb or postgresql
- _elasticsearch_
- _mailhog_
- _memcached_
- _redis_
- _redis-commander_
- _web_ running nginx
- _worker_ running workspace code (_--tries_ set to 1)
