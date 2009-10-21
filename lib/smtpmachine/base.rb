module SMTPMachine
  
  class Base
    class << self
      def inherited(subclass)
        subclass.reset!
        super
      end
    end
    
    include Router

    attr_accessor :context
    
    reset!
    
    def call(env)
      @env = env
      @context = Context.new(env)

      route!
    end
  end
end
