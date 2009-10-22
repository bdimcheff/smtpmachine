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

    def remaining_actions
      a = context.action

      (States[0...States.index(a)] - state) << a
    end
    
    def call(env)
      @env = (self.env || {}).merge(env)
      @context = Context.new(env)

      match = false
      
      catch(:halt) do
        remaining_actions.each do |a|
          self.action = a
          res = !!route!
          match ||= res
          state << action
        end
        
        match
      end
    end
  end
end
