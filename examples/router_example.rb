require 'example_helper'

def route(email = 'foo@example.com')
  @router.new.route!(email)
end

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
    route
    
    mapped.should be_true
  end

  it 'allows methods to be called on the including object' do
    called = false

    @router.class_eval do
      map(/.*/) { called = true }

      def foo
        true
      end
    end
    
    @router.new.route!('')

    called.should be_true
  end
end
