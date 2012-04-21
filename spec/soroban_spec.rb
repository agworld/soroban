require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Soroban" do
  it "can create a new sheet" do
    s = Soroban::Sheet.new
  end
  it "can add two numbers" do
    s = Soroban::Sheet.new
    s.A1 = 2
    s.A2 = 3
    s.A3 = "=A1+A2"
    s.A3.should eq(5)
  end
end
