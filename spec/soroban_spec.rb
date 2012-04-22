require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Soroban" do

  let(:sheet) { Soroban::Sheet.new }

  it "can add two numbers" do
    sheet.x = 2
    sheet.y = 3
    sheet.f = "=x+y"
    sheet.f.should eq(5)
  end

  it "can rewrite Excel to Ruby" do
    sheet.A1 = "=foo(A1^2<>3)"
    sheet.A1?.should eq("=func_foo(@A1.get**2!=3)")
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
    sheet.set(:foo, 'hello')
    sheet.foo.should eq('hello')
  end

  it "can get a value" do
    sheet.foo = 'hello'
    sheet.get(:foo).should eq('hello')
  end

  it "can set an array" do
    sheet.set("A1:A5", [ 1, 2, 3, 4, 5 ])
    sheet.B1 = '=SUM(A1:A5)'
    sheet.B1.should eq(15)
  end

  it "can set a hash" do
    sheet.set("A1:B3", { 'one' => 'mot', 'two' => 'hai', 'three' => 'bah' } )
    sheet.C1 = '=VLOOKUP(A1:A5)'
    sheet.B1.should eq(15)
  end

  it "can iterate over all cells" do
    sheet.set("A1:B3", { 'one' => 'mot', 'two' => 'hai', 'three' => 'bah' } )
    sheet.cells.each do |label, contents|
      # TODO
    end
  end

  it "can bind variables to cells" do
    sheet.A1 = 0
    sheet.A2 = "=A1^2"
    sheet.bind(:input, :A1)
    sheet.bind(:output, :A2)
    sheet.input = 5
    sheet.output.should eq(25)
    sheet.bindings.keys.should include :input
    sheet.bindings.keys.should include :output
    sheet.bindings.values.should include :A1
    sheet.bindings.values.should include :A2
  end

  it "can define new functions" do
    sheet.define(:FOO, lambda { |a, b| 2 * a + b / 2 })
    sheet.A1 = 7
    sheet.A2 = 8
    sheet.A3 = "=foo(A1, A2)"
    sheet.A3.should eq(18)
    sheet.functions.each do |name|
      # TODO
    end
  end

  it "can report on undefined cells" do
    sheet.A3 = "=A2+foo(A3:B4)"
    expected = [:A2, :A3, :A3, :B3, :B4 ]
    sheet.undefined.map.sort.should eq(expected)
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
      sheet.set(:A1, "=3**2")
    }.should raise_error(Soroban::ParseError)
  end

end
