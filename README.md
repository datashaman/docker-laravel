# docker-laravel

A script for building Dockerfile and docker-compose.yml based on Laravel project requirements.

## Usage

Checkout the repository:

    git clone https://github.com/datashaman/docker-laravel.git
    cd docker-laravel

Generate _Dockerfile_ and _docker-compose.yml_ with:

    ./build.sh php7.2 beanstalkd mailhog memcached mariadb elasticsearch redis

Copy the following into your project folder:

- Dockerfile
- docker-compose.yml
- templates/nginx.conf
- templates/php-fpm.conf

If you want to put the templates somewhere else, adjust the paths in _Dockerfile_ and _docker-compose.yml_.

The _php-fpm.conf_ file is needed at build time (and maybe also runtime), and the _nginx.conf_ file is needed at runtime.

Edit your current _.env_ file and remove any references to hostnames of services you've just added.

For example, `DB_HOST`, `ELASTICSEARCH_HOST`, `MEMCACHED_HOST`, `REDIS_HOST`. These will be configured inside the Compose stack.

Remove any mail-related variables as well, _mailhog_ will handle that.

Bring the Compose stack up:

    docker-compose up

Once it's pulled and built everything see which ports are open:

    docker-compose ps

The stack exposes the following HTTP endpoints:

- [beanstalkd console](http://127.0.0.1:2080)
- [mailhog](http://127.0.0.1:8025)
- [minio](http://127.0.0.1:9000)
- [web app](http://127.0.0.1:8080)
- [redis commander](http://127.0.0.1:8081)

The _app_ uses the _PHP-FPM_ binary, but can also be used for CLI usage. Do something like this to run your migrations and setup up your instance's data:

- docker-compose run app composer install
- docker-compose run app php artisan migrate --seed

Typing that all the time is a _PITA_, so setup an alias in your _.bashrc_ or similar:

    alias dcra='docker-compose run app'

And use it like this:

    dcra composer install
    dcra php artisan migrate --seed

Services available in the stack:

- _app_ running workspace code
- _beanstalkd_
- _beanstalkd-console_
- _db_ running mysql, mariadb or postgresql
- _elasticsearch_
- _mailhog_
- _memcached_
- _minio_
- _redis_
- _redis-commander_
- _web_ running nginx
- _worker_ running workspace code (_--tries_ set to 1)

The sample _Dockerfile_ and _docker-compose.yml_ files in this repo build all the above (using _mariadb_ as _db_).
