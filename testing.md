A properly designed API should return two things: 
an HTTP response status-code and the response body. Testing the status-code is necessary for web applications with user authentication and resources with different permissions. That being said, testing the response body should just verify that the application is sending the right content.

HTTP Status Codes
Typical HTTP responses for a simple API on an application with authentication will generally fall within the following 4 status codes:

200: OK - Basically self-explanitory, the request went okay.
401: Unauthorized - Authentication credentials were invalid.
403: Forbidden - The resource requested is not accessible - in a Rails app, this would generally be based on permissions.
404: Not Found - The resource doesn’t exist on the server.

It goes without saying that the content body should contain the resources that you requested and shouldn’t contain attributes that are private. This is straight forward for GET requests, but what if you’re sending a POST or DELETE request? Your test should also ensure that any desired business logic gets completed as expected.