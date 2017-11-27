Startup Option Trading Platform
===

Secondary Marketplace for Startup options. It also provides a nicer way
to browse the [gruenderszene.de](https://gruenderszene.de) database of
startups. Making it easier to see how many an individual investments an
investor has, for example.

Docker
---

First install [Docker](https://docker.com) and then do:

    docker volume create --name=srtupnetdb
    docker volume create --name=srtupnetenv
    docker network create srtupnet

    docker-compose build
    docker-compose up

The ```up``` command will always restart the web server. The migration server
should not be restarted since this will only run we needed.

Legal
---

WARNING: THIS CODE CAUSES COPYRIGHT INFRINGEMENT.

The initial database is scraped from
[gruenderszene.de](https://gruenderszene.de). That is illegal in most
parts of this planet. Which means, even though this code is open
source, do not host it on a public facing server.

The author does not take responsibility for the stupidity of other people.

END OF WARNING.

License
---

GPLv3
