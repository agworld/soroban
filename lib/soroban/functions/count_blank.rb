# Count how many blank outputs there are in a range
# To match the Excel function it should be blank output from
# both static and dynamic values of a cell ( ie static or calculated )
Soroban::define :COUNTBLANK => lambda { |*args|
  Soroban::getValues( binding, *args ).reduce(0) do |sum, value|
    # Values could be string or numeric...
    if value.to_s.empty?
      sum += 1
    end

    sum
  end
}
