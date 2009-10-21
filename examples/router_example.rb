require 'example_helper'
require 'ostruct'

def route(email = 'foo@example.com')
  router = @router.new
  router.context.rcpt_to = email
  router.action = :data
  router.route!
end

describe 'SMTPMachine::Router' do
  before(:each) do
    @router = Class.new do
      include SMTPMachine::Router
      attr_accessor :context, :action

      reset!
      
      def initialize
        self.context = OpenStruct.new
      end
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
    
    route

    called.should be_true
  end

  it 'calls all blocks that match' do
    called = ''

    @router.class_eval do
      map(/.*/) { called += "*" }
      map(/foo/) { called += "foo" }
      map(/bar/) { called += "bar" }
    end
    
    route

    called.should == '*foo'
  end

  it "passes to the next match when pass is called" do
    called = ''
    
    @router.class_eval do
      map(/.*/) { pass; called += "fail" }
      map(/.*/) { called += "win" }
    end

    route

    called.should == 'win'
  end

  it "halts all processing when halt is called" do
    called = ''
    
    @router.class_eval do
      map(/.*/) { halt; called += "fail" }
      map(/.*/) { called += "fail" }
    end

    route

    called.should == ''
  end

  
end
