# A scoped, module based code loading for Ruby

This is an experimental project to ascertain the utility and practicality of an
opt-in, scoped code loading mechanism.

`require` evaluates the target Ruby code within the global namespace creating
new constants or modifying existing ones.

`module_require` aims to provide a mechanism for loading files into modules
such that imported code is scoped, preventing unintentional pollution of the
global namespace and allowing the user more control over dependencies.

## Features

* Load two versions of the gem
* Load a gem into an anonymous module such that access to it can be private
* Whitelist top level constants

## Caveats

Ruby offers no real safety or restrictions so any of these features can of
course be circumvented as simply as using absolute constant lookup eg
`::MyModule` or `Object::MyModule`.

## Goals

* Work without VM modifications
* Compatibility with existing popular libraries
* Code that is approachable

## Example

```ruby
module MyTopLevelModule
  module_require "some_library"
end

::Object.constants.include?(:SomeLibrary)
# => false

MyTopLevelModule.constants.include?(:SomeLibrary)
# => true
```
