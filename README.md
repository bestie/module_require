
# A better require for Ruby

This is an experimental project to improve how modules are loaded and namespaces
are handled.

## The problem

Managing dependencies is hard and the Bundler team have to make herculean
efforts to manage them for us. The core problem being that you can't load two
versions of same gem as they would both try to overwrite eachothers top-level
module.

## The solution

Provide a mechanism for loading files into modules such that you have control
over the population of your own global namespace.

So the following would load `SomeLibrary` into `MyTopLevelNamespace`.

```ruby
module MyTopLevelModule
  better_require "some_library"
end
```

## Goals

* Work without VM modifications
* Compatibility with existing popular libraries
* Code that isn't *too* mental

## Future

* Java style imports allowing the user to choose which constants are loaded
