**Circuit is in heavy development and reorganization at the moment.  We are planning to have this API and change
stabilized in the 0.4.0 release.  0.4.0 and future releases will include deprecation warning and a 0.4.0-stable 
branch in GitHub.**

# Circuit

<<< description.md

**GitHub** http://github.com/maxmedia/circuit

**Issues** http://github.com/maxmedia/circuit/issues

**Travis-CI** http://travis-ci.org/maxmedia/circuit
[![Build Status](https://secure.travis-ci.org/maxmedia/circuit.png?branch=master)](http://travis-ci.org/maxmedia/circuit)

**Docs** http://maxmedia.github.com/circuit

**RubyGems** http://rubygems.org/gems/circuit

## Contributing

Anyone is welcome to contribute to circuit.  Just [fork us on GitHub](https://github.com/maxmedia/circuit/fork_select)
and send a pull request when you are ready.

Please ensure the following compatibility requirements are met.

<<< docs/COMPATIBILITY.md

## A common discussion ensues.

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

## A mapping graph to route rack requests.

TODO

## Rackup-based behaviors.

Circuit uses behaviors to extend a requests functionality in the rack stack.  Behaviors are written
and stored in circuit-rackup files (`.cru`).  The difference between a normal rackup file and a 
circuit-rackup file is that a circuit-rackup file does not have to have a `run` declaration; this 
makes circuit-rackup files only *partially* rackup compliant. Below is an example of a behavior 
that renders an ok response (this is a fully-compliant rackup file; however, we still use the 
`.cru` extension for the behavior):

    # ./app/behaviors/render_ok.cru
    
    run proc {|env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
    

First, setup your `Site`:

    $ > @site = Circuit::Site.new(host: "example.com", aliases: ["www.example.com"])
    $ > @site.save
    $ => true

Then, setup your `Node` and specify the behavior:

    $ > @node = Circuit::Node.new(slug: "", behavior_klass: "RenderOk")
    $ > @node.site = @site
    $ > @node.save
    $ => true
    $ > @node.root? # the blank slug indicates the root
    $ => true
    $ > @node.behavior
    $ => RenderOk
    $ > @node.behavior.class
    $ => Module
    $ > @node.behavior.included_modules
    $ => [Circuit::Behavior]
    
When your site is loaded, the render_ok.ru behavior will be executed.

Behaviors are loaded into memory during application initialization.  Any modifications to behaviors 
will require restarting your application.

## Circuit::Middleware::Rewriter

One useful middleware baked into circuit is the `Rewriter`.  The idea of this middleware is 
to use circuit routing to route to dynamic content you have associated in you routing tree.

    # ./app/behaviors/page.ru
    
    use Circuit::Middleware::Rewriter do |request|
      content = request.route.last.content
      ["/#{content.class.to_s.underscore.pluralize}", "/#{content.id}"]
    end

and the corresponding downstream rails file:

    # ./config/routes.rb
    
    Rails.application.routes.draw do
      resources :contents
    end

In the above example, we are assuming you have created a model that has a content object associated 
to it.  By doing this we have now created a small CMS.

## Multi-Backend support

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

<<< docs/ROADMAP.md

-----------------------------------------------
```
<<< LICENSE
```