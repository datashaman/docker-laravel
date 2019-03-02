#!/usr/bin/env bash

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

generate_dockerfile () {
    declare -a APT
    declare -a KEYS
    declare -A SOURCES

    for PACKAGE in ${BUILD_PACKAGES[@]}
    do
        case $PACKAGE in
            php*)
                echo "Add apt packages for $PACKAGE"
                APT+=(
                    $PACKAGE-bcmath
                    $PACKAGE-curl
                    $PACKAGE-fpm
                    $PACKAGE-gd
                    $PACKAGE-intl
                    $PACKAGE-mbstring
                    $PACKAGE-sqlite3
                    $PACKAGE-xml
                    $PACKAGE-zip
                )
                ;;
            mariadb | mysql | postgresql)
                echo "Add apt client package for $PACKAGE"
                APT+=($PACKAGE-client)
                ;;
            memcached)
                echo "Add apt client package for $PACKAGE"
                APT+=(php-memcached)
                ;;
            node*)
                VERSION=${PACKAGE#node}
                [ -z "$VERSION" ] && VERSION=11
                echo "Add apt package for node${VERSION}"
                KEYS+=(https://deb.nodesource.com/gpgkey/nodesource.gpg.key)
                SOURCES[nodesource]="deb https://deb.nodesource.com/node_${VERSION}.x bionic main"
                APT+=(nodejs)

                echo "Add apt package for yarn"
                KEYS+=(https://dl.yarnpkg.com/debian/pubkey.gpg)
                SOURCES[yarn]="deb https://dl.yarnpkg.com/debian/ stable main"
                APT+=(yarn)
                ;;
            redis)
                echo "Add apt tools package for $PACKAGE"
                APT+=($PACKAGE-tools)
                ;;
        esac
    done

    echo "Build Dockerfile"
    cp templates/Dockerfile Dockerfile

    PACKAGES="${BUILD_PACKAGES[@]}"
    sed -i "s!%%BUILD_MIRROR%%!${BUILD_MIRROR}!g
s!%%BUILD_PACKAGES%%!${PACKAGES}!g
s!%%BUILD_USER%%!${BUILD_USER}!g" Dockerfile

    {
        echo ""

        if [ ${#KEYS[@]} -gt 0 ]
        then
            echo "# Add apt keys" 
            for KEY in "${KEYS[@]}"
            do
                echo "RUN curl -sS $KEY | apt-key add - > /dev/null" 
            done
            echo "" 
        fi

        if [ ${#SOURCES[@]} -gt 0 ]
        then
            echo "# Add apt sources" 
            for NAME in "${!SOURCES[@]}"
            do
                SOURCE=${SOURCES[$NAME]}
                FILE=/etc/apt/sources.list.d/${NAME}.list
                echo "RUN echo ${SOURCE} > $FILE" 
            done
            echo "" 

            echo "# Update apt repositories" 
            echo "RUN apt-get update -y" 
            echo "" 
        fi

        echo "# Install apt packages" 
        echo "RUN apt-get install -yq --no-install-recommends \\" 

        IFS=$'\n' SORTED_APT=($(sort <<<"${APT[*]}"))
        unset IFS

        INDEX=1
        COUNT=${#APT[@]}

        for PACKAGE in "${SORTED_APT[@]}"
        do
            printf "   ${PACKAGE}" 

            if [ $INDEX -lt $COUNT ]
            then
                echo " \\" 
            else
                echo "" 
            fi

            ((INDEX++))
        done

        echo "" 

        echo "COPY templates/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf"
        echo -n 'RUN sed -i "s#%%BUILD_USER%%#${BUILD_USER}#g"'
        echo " /etc/php/${PHP_VERSION}/fpm/php-fpm.conf"
        echo ""

        echo "# Install composer" 
        echo "RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer" 
        echo "" 

        echo "# Install bower brunch gulp-cli" 
        echo "RUN npm install bower brunch gulp-cli -g" 
        echo "" 

        echo 'RUN mkdir /workspace && chown ${BUILD_USER} /workspace'
        echo "WORKDIR /workspace"
        echo 'USER ${BUILD_USER}' 
        echo "" 

        echo "# Install prestissimo composer package" 
        echo "RUN composer global require hirak/prestissimo" 

        echo "EXPOSE 9000"
        echo 'CMD ["/usr/sbin/php7.2-fpm"]'
    } >> Dockerfile
}

generate_app_service () {
    NAME=$1

    for PACKAGE in ${BUILD_PACKAGES[@]}
    do
        case $PACKAGE in
            php*)
                printf "  $NAME:\n"
                printf "    build: .\n"

                [ "$NAME" == "app" ] && printf "    user: root\n"
                [ "$NAME" == "app" ] && printf "    command: ['/usr/sbin/php-fpm7.2']\n"
                [ "$NAME" == "worker" ] && printf "    command: ['php', 'artisan', 'queue:work', '--tries=1', '-vv']\n"

                printf "    env_file: .env\n"
                printf "    environment:\n"

                for KEY in "${!ENVIRONMENT[@]}"
                do
                    printf "      - $KEY=${ENVIRONMENT[$KEY]}\n"
                done

                printf "    depends_on:\n"

                for SERVICE in "${DEPENDS_ON[@]}"
                do
                    printf "      - $SERVICE\n"
                done

                printf "    volumes:\n"
                printf "      - ./:/workspace\n"
                echo ""
                ;;
        esac
    done
}

generate_docker_compose () {
    declare -a DEPENDS_ON
    declare -A ENVIRONMENT

    echo "Build docker-compose.yml"
    cp templates/docker-compose.yml docker-compose.yml

    PACKAGES="${BUILD_PACKAGES[@]}"
    sed -i "s!%%BUILD_PACKAGES%%!${PACKAGES}!g" docker-compose.yml

    {
        echo ""
        echo "services:"

        for PACKAGE in ${BUILD_PACKAGES[@]}
        do
            case $PACKAGE in
                beanstalkd)
                    DEPENDS_ON+=(beanstalkd)
                    ENVIRONMENT[QUEUE_HOST]=beanstalkd
                    VOLUMES+=(beanstalkd)
                    sed 's/^/  /' templates/beanstalkd.yml
                    echo ""
                    ;;
                elasticsearch)
                    ENVIRONMENT[ELASTICSEARCH_HOST]=elasticsearch:9200
                    sed 's/^/  /' templates/elasticsearch.yml
                    echo ""
                    ;;
                mariadb)
                    containsElement "db" "${DEPENDS_ON[@]}" || DEPENDS_ON+=(db)
                    ENVIRONMENT[DB_HOST]=db
                    sed 's/^/  /' templates/mariadb.yml
                    echo ""
                    ;;
                memcached)
                    DEPENDS_ON+=(memcached)
                    ENVIRONMENT[MEMCACHED_HOST]=memcached
                    sed 's/^/  /' templates/memcached.yml
                    echo ""
                    ;;
                mysql)
                    containsElement "db" "${DEPENDS_ON[@]}" || DEPENDS_ON+=(db)
                    ENVIRONMENT[DB_HOST]=db
                    sed 's/^/  /' templates/mysql.yml
                    echo ""
                    ;;
                postgresql)
                    containsElement "db" "${DEPENDS_ON[@]}" || DEPENDS_ON+=(db)
                    ENVIRONMENT[DB_HOST]=db
                    sed 's/^/  /' templates/postgresql.yml
                    echo ""
                    ;;
                redis)
                    DEPENDS_ON+=(redis)
                    ENVIRONMENT[REDIS_HOST]=redis
                    VOLUMES+=(redis)
                    sed 's/^/  /' templates/redis.yml
                    echo ""
                    ;;
            esac
        done

        sed 's/^/  /' templates/nginx.yml
        echo ""

        generate_app_service app
        generate_app_service worker

        if [ ${#VOLUMES[@]} -gt 0 ]
        then
            printf "volumes:\n"

            for VOLUME in "${VOLUMES[@]}"
            do
                printf "  $VOLUME:\n"
            done
        fi
    } >> docker-compose.yml
}

. .env

declare -a BUILD_PACKAGES

if [ $# -gt 0 ]
then
    for i in {1..$#}
    do
        BUILD_PACKAGES+=($[$i])
    done
fi

for PACKAGE in ${BUILD_PACKAGES[@]}
do
    case $PACKAGE in
        php*)
            PHP_VERSION=${PACKAGE#php}
            [ -z "$PHP_VERSION" ] && PHP_VERSION=7.2
            ;;
        node*)
            FOUND_NODE=true
            ;;
    esac
done

if [ ! $PHP_VERSION ]
then
    PHP_VERSION=7.2
    BUILD_PACKAGES+=(php7.2)
fi

if [ ! $FOUND_NODE ]
then
    BUILD_PACKAGES+=(node11)
fi

generate_dockerfile
generate_docker_compose
