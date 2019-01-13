# rite-club-web

This web app is essentially a fancy, browseable database to Rites and
matches of several Rites conducted for the Rite Club.

A RESTful HTTP API is exposed, too, mainly to be used by the Rite Club
Companion app, which makes posting games to the database very easy and
tightly integrated into Pyre itself.


## Environment variables

The web application respects the following environment variables:

- **`NO_MEMCACHED`** -- If this is set to a nonempty string, then we set up
  the "fake cache" which allows database queries to be made without
  requiring `memcached` to be running, too.

- **`MEMCHACED_URI`** -- Pointer to the memcached service. Defaults to
  `localhost:11211`.

- **`RACK_ENV`** -- The standard Rack environment name. Default:
  `development`.

- **`DB_URI`** -- Sequel identifier for the SQL database. By default it is
  `sqlite://$(DB_DIR)/$(RACK_ENV).sqlite3`, which typically resolves to
  `sqlite://$(pwd)/db/development.sqlite3`.

- **`S3_BUCKET_URL`** -- A HTTP "prefix" which signifies where static assets
  are located. By default it is simply "/", which indicates that the HTTP
  server will serve these "public" items directly from the `./public`
  folder next to this README. Otherwise, the value you'll probably want to
  set this to is: `https://s3-us-west-2.amazonaws.com/noxalasdotnet/public`.
