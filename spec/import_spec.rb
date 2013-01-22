require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

has_rubyxl = begin
  Gem::Specification::find_by_name("rubyXL") 
rescue Gem::LoadError
  false
end

describe "Documentation", :if => has_rubyxl do

  it "can import xlsx files using RubyXL" do

    BINDINGS = {
      :planet => :B1,
      :mass => :B2,
      :force => :B3
    }

    s = Soroban::Import::rubyXL("files/Physics.xlsx", 0, BINDINGS )

    s.planet = 'Earth'
    s.mass = 80
    puts s.force          # => 783.459251241996
    s.force.should be_within(0.01).of(783.46)

    s.planet = 'Venus'
    s.mass = 80
    puts s.force          # => 710.044826106394
    s.force.should be_within(0.01).of(710.04)

    require 'benchmark'

    i_time = Benchmark.realtime do
      1000.times do
        s.planet = 'Earth'
        s.mass = 80
        s.force
        s.planet = 'Venus'
        s.mass = 80
        s.force
      end
    end

    puts "Interpreted Time: #{i_time}"

    eval(s.to_ruby("Test"))
    model = Soroban::Model::Test.new

    model.planet = 'Earth'
    model.mass = 80
    model.force.should be_within(0.01).of(783.46)

    model.planet = 'Venus'
    model.mass = 80
    model.force.should be_within(0.01).of(710.04)

    c_time = Benchmark.realtime do
      1000.times do
        model.planet = 'Earth'
        model.mass = 80
        model.force
        model.planet = 'Venus'
        model.mass = 80
        model.force
      end
    end

    puts "Compiled Time: #{c_time}"

    (10.0 * c_time).should be < i_time 

  end

end
