module SMTPMachine
  
  class Base
    States = [:ehlo, :mail_from, :rcpt_to, :data]
    
    class << self
      def inherited(subclass)
        subclass.reset!
        super
      end
    end
    
    include Router

    attr_accessor :context, :state, :action, :env
    
    reset!

    def initialize
      self.state = []
    end
        
    def call(env)
      @env = env
      @context ||= Context.new
      @context.add(env)

      match = false
      
      catch(:halt) do
        self.action = context.action
        res = !!route!
        match ||= res
        state << action
        match
      end
    end
  end
end
