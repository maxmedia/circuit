Circuit is a rack application middleware that enables dynamic request mapping.  Modeled after 
[Rack::Builder](https://github.com/rack/rack/blob/master/lib/rack/builder.rb), Circuit provides 
for a tree of url-mappings that is walked at request time.  If you are interested in dynamically 
loading middleware and functionality into requests, circuit is a viable solution to do that in a 
maintainable way.
