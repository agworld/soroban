require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Documentation", :if => defined?(RubyXL) do

  it "importers work" do
    BINDINGS = {
      :planet => :B1,
      :mass => :B2,
      :force => :B3
    }

    s = Soroban::Import::rubyXL("files/Physics.xlsx", 0, BINDINGS)

    s.planet = 'Earth'
    s.mass = 80
#   puts s.force          # => 783.459251241996
    s.force.should be_within(0.01).of(783.46)

    s.planet = 'Venus'
    s.mass = 80
#   puts s.force          # => 710.044826106394
    s.force.should be_within(0.01).of(710.04)
  end

end
