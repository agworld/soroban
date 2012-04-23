Soroban
=======

Soroban is a calculating engine that understands Excel formulas.

Getting Started
---------------

```
> sudo gem install soroban
```

Example Usage
-------------

```ruby
require 'soroban'

s = Soroban::Sheet.new()

s.A1 = 2
s.set('B1:B5', [1,2,3,4,5])
s.C1 = "=SUM(B1:B5) + A1 ^ 3"
s.C2 = "=IF(C1>25,'Large','Tiny')"

puts s.C1             # => 23

s.bind(:input, :A1)
s.bind(:output, :C2)

puts s.output         # => "Tiny"

s.input = 3

puts s.output         # => "Large"
puts s.C1             # => 42
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

s.missing             # => [:E1, :D1, :D2, :D3, :D4, :D5]

s.E1 = "= D1 ^ D2"
s.set("D1:D5", [1,2,3,4,5])

s.missing             # => []

s.cells               # => {"F1"=>"= E1 + SUM(D1:D5)", "E1"=>"= D1 ^ D2", "D1"=>"1", "D2"=>"2", "D3"=>"3", "D4"=>"4", "D5"=>"5"}
```

This means parsing a file can be done as follows.

* Add the cells that correspond to inputs and outputs
* Add the cells reported by `missing` (and continue to do so until it's empty)
* Persist the hash returned by `cells`

Iteration
---------

Note that `cells` returns the label of the cell along with its raw contents. If
you want to iterate over cell values (including computed values of formulas),
then use `walk`.

```ruby
s.set('D1:D5', [1,2,3,4,5])
s.walk('D1:D5').reduce(:+)    # => 15
```

Functions
---------

Soroban implements some Excel functions, including `IF`, `SUM`, `VLOOKUP`,
`HLOOKUP`, `MIN`, `MAX` and `AVERAGE`, but you may find that you need more than
those. In that case, it's easy to add more.

```ruby
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

Copyright (c) 2012 Agworld Pty. Ltd. See LICENSE.txt for further details.
