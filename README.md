**Circuit is in heavy development and reorganization at the moment.  We are planning to have this API and change
stabilized in the 0.4.0 release.  0.4.0 and future releases will include deprecation warning and a 0.4.0-stable 
branch in github.**

# circuit

Circuit is a rack application middleware that enables dynamic request mapping.  Modeled after 
[Rack::Builder](https://github.com/rack/rack/blob/master/lib/rack/builder.rb), Circuit provides 
for a tree of url-mappings that is walked at request time.  If you are interested in dynamically 
loading middleware and functionality into requests, circuit is a viable solution to do that in a 
maintainable way.

### a common discussion ensues.

**Q: But why would someone need database powered Rack::Builder?**

Response: The rack ecosystem doesn't have a good way to handle dynamic http routing.  Circuit meets the 
needs of dynamic routing while preserving the functionality that Rack provides.  

**Comment: That seems really... slow.**

Response: A valid point, but circuit isn't for every codebase.  If you need dynamic routing (i.e. 
using splat routing methods followed by a database lookup), you are going to see similar 
performance to circuits backends.  Along with that, circuit provides a number of useful features 
that far outweigh performance costs.

**Comment: this isn't very _Railsy_**

Response: In practice, codebases that use circuit to solve dynamic routing are **more** railsy.  
Let me explain:

If you are constructing an application in Rails that requires dynamic user specified slugs, you 
probably have this line uncommented from your routes: 

    # yuck.
    match '/*', to: 'site#proxy'
    
Say you are creating a CMS using this line.  This means that that one action will handle all 
requests that don't match the rest of your routes definition.  Immediately this might seem like a good 
idea, but it will inevitably lead to a very expensive Rails action that handles a large number of 
requests on the site.

Circuit will allow you to remove this line and use middlewares to route requests to different 
controllers (even rack applications), and control this logic via the backend of your choice. 
Routes can be extended with their specified behaviors, allowing even more control over requests 
than rails provides out of the box.

Using the Rerouting Middleware you can easily reroute downstream requests to standard-issue rails 
controllers, enabling your dynamic requests to add middleware, modify the rack request object and 
even change your downstream app (to another rack app).

### a mapping graph to route rack requests.

TODO

### .ru-based behaviors.

Circuit uses behaviors to extend a requests functionality in the rack stack.  Behaviors written and 
stored in rackup files.  Below is an example of a behavior that renders an ok response:

    # ./app/behaviors/render_ok.ru
    
    run proc {|env| [200, {'Content-Type' => 'text/plain'}, ['ok']] }
    
Within your Site or Route specify your behavior:

    $> @site = Site.first
    $> @site.behavior_file = :render_ok
    $ => true
    $> @site.save
    
When your site is loaded, the render_ok.ru behavior will be executed.

Behaviors are loaded into memory during application initialization.  Any modifications to behaviors 
will require restarting your application.

### Behaviors::RewriteDownstream

One useful middleware baked into circuit is the `RewriteDownstream`.  The idea of this middleware is 
to use circuit routing to route to dynamic content you have associated in you routing tree.

    # ./app/behaviors/page.ru
    
    use Rack::DownstreamRewrite do |env|
      content = env["rack.circuit.current_route"].content
      env["PATH_INFO"] = "/#{content.class.to_s.underscore.pluralize}/#{content.id}"
    end
    
and the corresponding downstream rails file:

    # ./config/routes.rb
    
    Rails.application.routes.draw do
      resources :contents
    end
    
In the above example, we are assuming you have created a model that has a content object associated 
to it.  By doing this we have now created a small CMS.

### Multi-Backend support

Circuit provides support for different backends to power this map tree. Currently, the gem includes a 
Mongoid backend and a memory backend.  Each backend is how Circuit is constructed to interface with your
persisted routing tree.  Backends are ActiveModel based.

Currently, Backends are ActiveModel backed and within them they define the model that the router interacts 
with. We are discussing the idea of separating the backends from the model (to drop the ActiveModel dependency).

**This is where circuit needs your help!**  We would love to see backends for many common ODM's.  Our 
hit-list includes:

* <del>Mongoid</del>
* <del>Memory</del>
* Yaml
* Redis
* ActiveRecord
* RiakClient/Ripple

We will entertain pull requests from other commonly used libraries.

## roadmap

### 0.2.0

* <del>better readme</del>
* <del>Separate site and routing tree</del>
* <del>database site aliases</del>
* <del>multi-backend support</del>
* <del>travis-ci</del>
* Move to github issues.
* Remove rails dependencies.
* Behaviors are specified in rackup files, instead of classes.
* Behaviors support full Rack::Builder; including `run`, `use`, and `map` methods.

### 0.3.0

* tree inheritable middlewares.
* full documentation. 

### 0.4.0

* API stability

### In the future

* Goliath support

-----------------------------------------------

Copyright (c) 2012 [MaxMedia](http://maxmedia.com)

[licensing info](http://github.com/maxmedia/circuit/blob/master/LICENSE)
