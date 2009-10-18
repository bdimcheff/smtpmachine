require 'example_helper'

describe 'SMTPMachine::Router' do
  before(:each) do
    @router = Class.new do
      include SMTPMachine::Router
    end
  end
  
  it 'has a map method' do
    @router.should respond_to(:map)
  end
  
  it 'maps all addresses' do
    mapped = false
    
    @router.map(/.*/) { mapped = true }
    @router.new.route!('foo@example.com')
    
    mapped.should be_true
  end

  it 'allows methods to be called on the including object' do
    @router.class_eval do
      def foo
        true
      end
    end
    
    called = false

    @router.map(/.*/) { called = true }
    @router.new.route!('')

    called.should be_true
  end
end
