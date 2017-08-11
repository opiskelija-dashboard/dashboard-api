Things that need testing:
[x] Configure Travis.
[x] leaderboard
    [x] returns status 200 
    [x] returns correct response body
[] token / controller tests?
    [] test all methods
    [] test both ways how to create token, authentication and testing
[] token controller
    [] when visiting /new-dash-session -> give username, get jwt-token (do they match?)
    [] when given invalid credentials, no jwt token given
    [] when given no token
    [] when wrong kind of data as credentials are given
[] application controller?
    [] when no jwt token given in headers
    [] when given correct jwt token in headers
    [] when given outdated signingkey in jwt token
    [] when given a "valid" token but expired
    [] when given a token with a valid signingkey but no content (no tmc-username, tmc-access-token etc.)
    * 'jwt.decode/jwt.encode'
    * 'http//jwt.io'
[x] cumulative point controller
    [x] returns status 200 
    [x] returns correct response body
    [x] replace jwt-token module lines with method call
[x] skill percentage controller
    [x] returns status 200 
    [x] returns correct response body
[x] create a helper module for token authorization

A properly designed API should return two things: 
an HTTP response status-code and the response body. Testing the status-code is necessary for web applications with user authentication and resources with different permissions. That being said, testing the response body should just verify that the application is sending the right content.

HTTP Status Codes
Typical HTTP responses for a simple API on an application with authentication will generally fall within the following 4 status codes:

200: OK - Basically self-explanitory, the request went okay.
401: Unauthorized - Authentication credentials were invalid.
403: Forbidden - The resource requested is not accessible - in a Rails app, this would generally be based on permissions.
404: Not Found - The resource doesn’t exist on the server.

It goes without saying that the content body should contain the resources that you requested and shouldn’t contain attributes that are private. This is straight forward for GET requests, but what if you’re sending a POST or DELETE request? Your test should also ensure that any desired business logic gets completed as expected.