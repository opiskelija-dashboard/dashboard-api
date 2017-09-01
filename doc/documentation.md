# Dashboard backend documentation

Various guides used during development:
 * [Building a JSON API with Rails 5](https://blog.codeship.com/building-a-json-api-with-rails-5/)
 * [json:api](http://jsonapi.org/format/), which some controllers follow but others don't
 * [Token-based authentication with Ruby on Rails 5 API](https://www.pluralsight.com/guides/ruby-ruby-on-rails/token-based-authentication-with-ruby-on-rails-5-api)
 * [Create a Rails 5 API with JWT](http://www.bentedder.com/part-3-create-a-rails-5-api-with-jwt-jsonwebtoken/)

A few explanations of a few things:
 
## The lifecycle of a session

The dashboard doesn't follow the traditional concept of the session.

The frontend page is embedded into a course material site. When a user
logs into the course material site, a "dashboard" button is shown.
When this button is clicked, the user is taken to the frontend page.

The user's login to the course material site is also a login to the TMC
server. The TMC server returns to the client (the browser) an access token,
that can be used for further requests to the TMC server (instead of
constantly passing around a username+password combo). The browser (more
accurately, the course material site's javascript code) stores this TMC
access token into the browser's LocalStorage, where it can be accessed by
all the pages of the course material site.

Because the dashboard frontend page is embedded into the course material
page, the dashboard frontend can read the TMC access token from the
browser's LocalStorage. However, we found that passing the TMC access token
by itself to the dashboard backend was insufficient, so we devised a separate
authentication scheme, using [JSON Web Tokens](https://jwt.io).

So, the dashboard frontend, with its access to the JWT token, starts its
relationship with the dashboard backend by first executing a POST request
to the backend's `/new-dash-session` endpoint. In the JSON-formatted body
of this POST request are the TMC username and TMC access token found in
the LocalStorage:

    POST /new-dash-session
    
    { "tmc_username": "ohtu_dashboard", "tmc_access_token":
    "9b6f8954f39f7835e5adc7e9d52644f784eb2fbcf4a4bfd40b5e2d1ea31501fe" }

The dashboard backend now uses this `tmc_access_token` to do requests to
the TMC server. The backend first asks the TMC server for the information
of the user that is associated with this particular key:

    GET /api/v8/users/current
    Authorization: Bearer 9b6f8954f39f7835e5adc7e9d52644f784eb2fbcf4a4bfd40b5e2d1ea31501fe

The TMC server responds with a JSON body:

    200 OK
    {"id":15653,"username":"ohtu_dashboard","email":"a@b","administrator":false}
    
    # or, alternatively:
    403 Forbidden
    {"errors":["Authentication required"]}

From this response, we know

 1. If the TMC access token we were given was really a TMC access token
 2. If the TMC username given was actually the username of who logged in
 3. The TMC user-ID of the user who logged in, which isn't stored in the browser;
 4. Whether the user who logged in is an administrator or not.

We can trust this information now. Now, there are two ways to store
trusted information like this: either store it in a database (in-memory
or on-disk), and use a session key to fetch it (the traditional method),
or give the information back to the user but cryptographically sign it
(the JWT method). We opted to follow this second method, as it seemed then
and still seems now to be less messy than having sessions to store.
This has the added benefit that the _server can now be stateless_:
the server can forget everything about the current request after the
request is over, not having to store session information itself.

We create a JWT token, with the payload containing the (now-tested)
TMC access token, the (now-verified) TMC username, the (now-known)
TMC user-ID and TMC admin bit, and an expiration time. We return this
JWT token to the dashboard frontend page, which stores it somewhere.

    200 OK
    {"data":{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0bWN1c3IiOiJvaHR
    1X2Rhc2hib2FyZCIsInRtY3RvayI6IjliNmY4OTU0ZjM5Zjc4MzVlNWFkYzdlOWQ1MjY0NGY3O
    DRlYjJmYmNmNGE0YmZkNDBiNWUyZDFlYTMxNTAxZmUiLCJ0bWN1aWQiOjE1NjUzLCJ0bWNhZG0
    iOmZhbHNlLCJleHAiOjE1MDQzMTAzOTl9.1J3BY6pEYB81JqYMUAWHO6MRyUNduyujc24LyrQf
    OxE","expires_at":1504310399}}

Now that the frontend has a JWT token, the frontend can execute requests
to other backend endpoints. For instance, to fetch cumulative points,
the frontend will format its request thusly, putting the JWT token in
an HTTP header named `Authorization`:

    GET /cumulative-points/course/1
    Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJ...jc24LyrQf0xE

The controller handling the `cumulative-points` endpoint will check this
`Authorization` header, decode the JWT token, verify its signature, and
allow or deny access to the endpoint. (Actually, the checking of the header
is done by `controller/application_controller.rb`, and the verification
of the token and its signature is done by `models/token.rb`.)

### JWT tokens, quickly

(I am well aware that the "T" in JWT
[stands for "token"](https://en.wikipedia.org/wiki/RAS_syndrome),
but I can't bring myself to refer to the token as just a "JW token".)

A JWT token is a three-part construction: a header, a body or "payload",
and a cryptographic signature. All three parts are Base64-encoded, and then
concatenated with periods, like so:

    eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0bWN1c3IiOiJvaHR1X2Rhc2hib2FyZ
    CIsInRtY3RvayI6IjliNmY4OTU0ZjM5Zjc4MzVlNWFkYzdlOWQ1MjY0NGY3ODRlYjJmYmN
    mNGE0YmZkNDBiNWUyZDFlYTMxNTAxZmUiLCJ0bWN1aWQiOjE1NjUzLCJ0bWNhZG0iOmZhb
    HNlLCJleHAiOjE1MDQzMTAzOTl9.1J3BY6pEYB81JqYMUAWHO6MRyUNduyujc24LyrQfOxE

The header and payload are just JSON which has been Base64-encoded to protect
it during transit, but the signature is binary data. Running the header
("eyJ0eX...NiJ9") and payload ("eyJ0bW...OTl9") thru a Base64 decoder
shows their true nature:

    Header:
    {"typ":"JWT","alg":"HS256"}
    Payload:
    {"tmcusr":"ohtu_dashboard","tmctok":
    "9b6f8954f39f7835e5adc7e9d52644f784eb2fbcf4a4bfd40b5e2d1ea31501fe",
    "tmcuid":15653,"tmcadm":false,"exp":1504310399}

The signature is the beautiful part of the token: we have (roughly)
hashed the header and payload, resulting in the signature. If the header
or payload change even by one bit, the signature changes. The signature
is done with a key known only to the server, so the user (or an attacker)
cannot forge a JWT token payload and have the signature be like that done
by the server. Because of this, we can trust whatever is in the payload.

## The raison_d'être of PointsStore

Some TMC courses are very big, having hundreds of students and hundreds
of exercises, multiplying together to give myriad awarded points.
Fetching all of the points of a course can thus retrieve a rather
considerable amount of data (in our tests 30~40 megabytes), which takes
a not-insignificant amount of time (~10 seconds over eduroam).

Without PointsStore, there would be no caching of these 40-megabyte requests.
Every time a user would access the dashboard, at least one of these requests
would be made, probably many. This delays the displayal of any data by
an aggravating amount of time and contributes to network congestion,
especially when there are many concurrent users.

PointsStore stores the result of these requests into a class-wide hash.
This isn't a pretty pattern, but we have found it to work well, and it
was faster to implement in our short timeframe than setting up an in-memory
database or storing it on disk.

(MockPointsStore is used for testing and development: it implements the
same interface as PointsStore, but instead of fetching data with a 10-second
request, it generates data with Ruby's pseudorandom number generator.)

## The Badge architecture

Badges, achievements, _haalarimerkit_, whatever. They were a pain to
implement. The current badge structure has three levels:

 - `Badge` objects represent a badge earned by the user.
 - `BadgeDef` objects represent the definition of a badge: its name, icon,
   and list of `BadgeCodes` that must all be true before the badge is awarded.
 - `BadgeCode` objects store snippets of Ruby that are evaluated for
   truthness or falseness.

The BadgeCode Ruby code is run in a function that looks like this:

    def f(user_id, data)
        # code goes here
    end

where `data` is a hash that possibly has the keys `user_points`,
`course_points`, and `exercises`. These are then arrays of hashes,
each being like that returned by the TMC server (more or less).

We implemented on the backend a way for creating new BadgeDefs and
BadgeCodes from the frontend, but the frontend doesn't have the
necessary widgets that these could be made. The BadgeDef/BadgeCode
CRUD endpoints all require the `tmcadm` bit set in the JWT token.
