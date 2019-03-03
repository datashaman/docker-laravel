test:
	[ -e .laravel ] || composer create-project --prefer-dist laravel/laravel .laravel "5.8.*" && exit 0
	./build.sh
	cp Dockerfile docker-compose.yml .laravel
	mkdir -p .laravel/templates 
	cp templates/nginx.conf templates/php-fpm.conf .laravel/templates
	cp DockerLaravelTest.php .laravel/tests/Feature
	cd .laravel && composer require pda/pheanstalk:~4.0 predis/predis:~1.0 elasticsearch/elasticsearch:^5.0
	cd .laravel && docker-compose run app ./vendor/bin/phpunit
