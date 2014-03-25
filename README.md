Soroban
=======

Soroban is a calculating engine that understands Excel formulas.

[![Code Climate](https://codeclimate.com/github/agworld/soroban.png)](https://codeclimate.com/github/agworld/soroban)
[![Dependency Status](https://gemnasium.com/agworld/soroban.png)](https://gemnasium.com/agworld/soroban)
[![Build Status](https://secure.travis-ci.org/agworld/soroban.png)](http://travis-ci.org/#!/agworld/soroban)


Getting Started
---------------

Simply `sudo gem install soroban` and then `require 'soroban'` in your code.

Look at the examples on this page, the [tests](https://github.com/agworld/soroban/blob/master/spec/soroban_spec.rb) and the [API docs](http://rubydoc.info/github/agworld/soroban/master/frames) to get up to speed.

Example Usage
-------------

```ruby
s = Soroban::Sheet.new()

s.A1 = 2
s.set('B1:B5' => [1,2,3,4,5])
s.C1 = "=SUM(A1, B1:B5, 5) + A1 ^ 3"
s.C2 = "=IF(C1>30,'Large','Tiny')"

puts s.C1             # => 30

s.bind(:input => :A1, :output => :C2)

puts s.output         # => "Tiny"

s.input = 3

puts s.output         # => "Large"
puts s.C1             # => 50
```

Bindings
--------

Soroban allows you to bind meaningful variable names to individual cells and to ranges of cells. When bound to a range, variables act as an array.

```ruby
s.set(:A1 => 'hello', 'B1:B5' => [1,2,3,4,5])

s.bind(:foo => :A1, :bar => 'B1:B5')

puts s.foo            # => 'hello'
puts s.bar[0]         # => 1

s.bar[0] = 'howdy'

puts s.B1             # => 'howdy'
```

Persistence
-----------

Soroban formulas are strings that begin with the `=` symbol. It is therefore
easy to persist them, which is mighty handy if you need to parse an Excel
spreadsheet, rip out formulas, store everything to a database and then perform
calculations based on user input.

Soroban makes this easy, as it can tell you which cells you need to add to make
it possible to do the calculations you want, and it can iterate over all the
cells you've defined, so you can easily rip them out for persistence.

```ruby
s.F1 = "= E1 + SUM(D1:D5)"

puts s.missing        # => [:E1, :D1, :D2, :D3, :D4, :D5]

s.E1 = "= D1 ^ D2"
s.set("D1:D5" => [1,2,3,4,5])

puts s.missing             # => []

s.cells               # => {:F1=>"= E1 + SUM(D1:D5)", :E1=>"= D1 ^ D2", :D1=>"1", :D2=>"2", :D3=>"3", :D4=>"4", :D5=>"5"}
```

Importers
---------

Soroban has a built-in importer for xlsx files. It requires the [RubyXL](https://github.com/gilt/rubyXL) gem. Use it as follows:

```ruby
BINDINGS = {
  :planet => :B1,
  :mass => :B2,
  :force => :B3
}

s = Soroban::Import::rubyXL("files/Physics.xlsx", 0, BINDINGS )

s.planet = 'Earth'
s.mass = 80
puts s.force          # => 783.459251241996

s.planet = 'Venus'
s.mass = 80
puts s.force          # => 710.044826106394
```

The above example parses the first sheet of Physics.xlsx, which you can [download](https://github.com/agworld/soroban/raw/master/files/Physics.xlsx).

This import process returns a new Soroban::Sheet object that contains all the
cells required to calculate the values of the bound variables, and which has the
bindings set up correctly.

You can import other kinds of file using the following pattern:

* Add the cells that correspond to bound inputs and outputs
* Add the cells reported by `missing` (and continue to do so until it's empty)
* Persist the hash returned by `cells`

Iteration
---------

Note that `cells` returns the label of the cell along with its raw contents. If
you want to iterate over cell values (including computed values of formulas),
then use `walk`.

```ruby
s.set('D1:D5' => [1,2,3,4,5])
s.walk('D1:D5').reduce(:+)    # => 15
```

Functions
---------

Soroban implements some Excel functions, but you may find that you need more
than those. In that case, it's easy to add more.

```ruby
Soroban::functions            # => ["AND", "AVERAGE", "EXP", "IF", "LN", "MAX", "MIN", "NOT", "OR", "SUM", "VLOOKUP"]

Soroban::define :FOO => lambda { |lo, hi|
  raise ArgumentError if lo > hi
  rand(hi-lo) + lo
}

s.g = "=FOO(10, 20)"

puts s.g              # => 17
```

Contributing to Soroban
-----------------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2014 Agworld Pty. Ltd. See LICENSE.txt for further details.
