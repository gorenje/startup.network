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
    docker-compose up # first time to load data into database
    docker-compose up # startup with a loaded database

The ```up``` command you will have to do a couple of times since the first
time it initializes the database and loads the base data (this will take
a longish amount of time). With the second ```up``` the website will come
and will be accessible.

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
