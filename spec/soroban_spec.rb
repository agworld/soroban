require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Soroban" do

  let(:sheet) { Soroban::Sheet.new }

  it "can add two numbers" do
    sheet.x = 2
    sheet.y = 3
    sheet.f = "=x+y"
    sheet.f.should eq(5)
    sheet.x -= 1
    sheet.f.should eq(4)
  end

  it "can iterate over a collection of cells" do
    sheet.A1 = 'a'
    sheet.B1 = 'b'
    sheet.A2 = 'c'
    sheet.B2 = 'd'
    data = sheet.walk('A1:B2').to_a
    data.sort.join.should eq('abcd')
  end

  it "can set a value" do
    sheet.set(:foo => 'hello')
    sheet.foo.should eq('hello')
  end

  it "can get a value" do
    sheet.foo = 'hello'
    sheet.get(:foo).should eq('hello')
  end

  it "can set an array" do
    sheet.set("A1:A5" => [ 1, 2, 3, 4, 5 ])
    sheet.set("B2" => 5)
    sheet.B1 = '=SUM(10, A1:A5, B2)'
    sheet.B1.should eq(30)
  end

  it "can set a hash" do
    sheet.set("A1:A3" => [ 'one', 'two', 'three' ], "B1:B3" => [ 'mop', 'hai', 'bah' ])
    sheet.C1 = '=VLOOKUP("two", A1:B3, 2, 0)'
    sheet.C1.should eq('hai')
  end

  it "can iterate over all cells" do
    sheet.set("A1:A3" => [ 1, 2, 3 ], "B1:B3" => [ 4, 5, 6 ], "C1:C3" => [ 7, 8, 9 ])
    sheet.cells.map { |label, contents| contents.to_i }.sort.should eq [1,2,3,4,5,6,7,8,9]
  end

  it "can bind variables to cells" do
    sheet.A1 = 0
    sheet.A2 = "=A1^2"
    sheet.bind(:input => :A1, :output => :A2)
    sheet.input = 5
    sheet.output.should eq(25)
    sheet.get(:input).should eq(5)
    sheet.bindings.keys.should include :input
    sheet.bindings.keys.should include :output
    sheet.bindings.values.should include :A1
    sheet.bindings.values.should include :A2
  end

  it "can bind variables to ranges" do
    sheet.set("X1:X5" => [1,2,3,4,5], "Z1:Z5" => [6,7,8,9,0])
    sheet.bind(:foo => "X1:X5", :bar => "Z1:Z5")
    sheet.foo[0].should eq(1)
    sheet.foo[4].should eq(5)
    sheet.bar[0].should eq(6)
    sheet.bar[3].should eq(9)
    sheet.bar[4].should eq(0)
    sheet.bar[2] = 'foo'
    sheet.Z3.should eq('foo')
  end

  it "can define new functions" do
    Soroban::define :FOO => lambda { |a, b| 2 * a + b / 2 }
    sheet.A1 = 7
    sheet.A2 = 8
    sheet.A3 = "=foo(A1, A2)"
    sheet.A3.should eq(18)
    Soroban::functions.should include 'FOO'
  end

  it "can report on missing cells" do
    sheet.A3 = "=A2+foo(A3:B4)"
    expected = [:A2, :A4, :B3, :B4 ]
    sheet.missing.should =~ expected
  end

  it "can detect loops when running formulas" do
    lambda {
      sheet.A1 = "=A2"
      sheet.A2 = "=A1"
      sheet.A2
    }.should raise_error(Soroban::RecursionError)
  end

  it "can reject valid ruby code in formulas" do
    lambda {
      sheet.set(:A1 => "=3**2")
    }.should raise_error(Soroban::ParseError)
  end

  it "can handle negative numbers" do
    sheet.set(:A1 => -10)
    sheet.set(:A2 => "-20")
    sheet.set(:A3 => '=-10+A2-A1')
    sheet.A3.should eq(-20)
  end

  it "can calculate natural logarithms" do
    sheet.set(:A1 => "=LN(#{Math::E})")
    sheet.A1.should eq(1.0)
  end

end
