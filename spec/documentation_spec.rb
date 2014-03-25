require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Documentation" do

  let(:s) { Soroban::Sheet.new }

  it "usage works" do
    s.A1 = 2
    s.set('B1:B5' => [1,2,3,4,5])
    s.C1 = "=SUM(A1, B1:B5, 5) + A1 ^ 3"
    s.C2 = "=IF(C1>30,'Large','Tiny')"

#   puts s.C1             # => 30
    s.C1.should eq(30)

    s.bind(:input => :A1, :output => :C2)

#   puts s.output         # => "Tiny"
    s.output.should eq('Tiny')

    s.input = 3

#   puts s.output         # => "Large"
    s.output.should eq('Large')
#   puts s.C1             # => 50
    s.C1.should eq(50)
  end

  it "bindings work" do
    s.set(:A1 => 'hello', 'B1:B5' => [1,2,3,4,5])

    s.bind(:foo => :A1, :bar => 'B1:B5')

#   puts s.foo            # => 'hello'
    s.foo.should eq('hello')
#   puts s.bar[0]         # => 1
    s.bar[0].should eq(1)

    s.bar[0] = 'howdy'
#   puts s.B1             # => 'howdy'
    s.B1.should eq('howdy')
  end

  it "persistence works" do
    s.F1 = "= E1 + SUM(D1:D5)"

#   s.missing             # => [:E1, :D1, :D2, :D3, :D4, :D5]
    s.missing.should =~ [:E1, :D1, :D2, :D3, :D4, :D5]

    s.E1 = "= D1 ^ D2"
    s.set("D1:D5" => [1,2,3,4,5])

#   s.missing             # => []
    s.missing.should =~ []

#   s.cells               # => {:F1=>"= E1 + SUM(D1:D5)", :E1=>"= D1 ^ D2", :D1=>"1", :D2=>"2", :D3=>"3", :D4=>"4", :D5=>"5"}
    s.cells.keys.should =~ [:F1, :E1, :D1, :D2, :D3, :D4, :D5]
    s.cells[:D3].should eq("3") 
  end

  it "iteration works" do
    s.set('D1:D5' => [1,2,3,4,5])
#   s.walk('D1:D5').reduce(:+)    # => 15
    s.walk('D1:D5').reduce(:+).should eq(15)
  end

  it "functions work" do
#   Soroban::functions    # => ["AND", "AVERAGE", "EXP", "IF", "LN", "MAX", "MIN", "NOT", "OR", "SUM", "VLOOKUP"]
    Soroban::Functions.all.should =~ ["AND", "AVERAGE", "EXP", "IF", "LN", "MAX", "MIN", "NOT", "OR", "SUM", "VLOOKUP"]

    Soroban::Functions.define :FOO => lambda { |lo, hi|
      raise ArgumentError if lo > hi
      rand(hi-lo) + lo
    }

    s.g = "=FOO(10, 20)"

#   puts s.g              # => 17
    s.g.between?(10, 20).should be_true
  end

end
