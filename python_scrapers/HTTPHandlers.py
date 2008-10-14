
from urllib2 import HTTPRedirectHandler

class CookieAddingHTTPRedirectHandler(HTTPRedirectHandler):
    """The standard python HttpRedirectHandler doesn't add a cookie to the new request after a 302. This handler does."""

    def __init__(self, cookie_jar):
        self.cookie_jar = cookie_jar

        # This really ought to call the superclasses init method, but there doesn't seem to be one.


    def redirect_request(self, *args):
        new_request = HTTPRedirectHandler.redirect_request(self, *args)
        # We need to add a cookie from the cookie_jar
        self.cookie_jar.add_cookie_header(new_request)

        return new_request
