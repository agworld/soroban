require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Soroban" do

  let(:sheet) { Soroban::Sheet.new }

  it "can add two numbers" do
    sheet.A1 = 2
    sheet.A2 = 3
    sheet.A3 = "=A1+A2"
    sheet.A3.should eq(5)
  end

  it "can rewrite Excel to Ruby" do
    sheet.A1 = "=foo(A1^2<>3)"
    sheet.A1?.should eq("=func_foo(_A1**2!=3)")
  end

end
