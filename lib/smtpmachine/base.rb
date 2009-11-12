module SMTPMachine
  
  class Base
    States = [:ehlo, :mail_from, :rcpt_to, :data]
    
    class << self
      def inherited(subclass)
        subclass.reset!
        super
      end
      
      # Define a metaclass method.  Cold stolen from Sinatra.
      def metadef(message, &block)
        (class << self; self; end).
          send :define_method, message, &block
      end
      
      # Sets an option to the given value.  If the value is a proc,
      # the proc will be called every time the option is accessed.
      # Cold stolen from Sinatra
      def set(option, value=self)
        if value.kind_of?(Proc)
          metadef(option, &value)
          metadef("#{option}?") { !!__send__(option) }
          metadef("#{option}=") { |val| set(option, Proc.new{val}) }
        elsif value == self && option.respond_to?(:to_hash)
          option.to_hash.each { |k,v| set(k, v) }
        elsif respond_to?("#{option}=")
          __send__ "#{option}=", value
        else
          set option, Proc.new{value}
        end
        self
      end
    end
    
    include Router

    attr_accessor :context, :state, :action, :env
    
    reset!
    
    set :host, '0.0.0.0'
    set :port, 25

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
