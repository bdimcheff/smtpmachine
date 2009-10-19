module SMTPMachine
  
  class Base
    class << self
      # The prototype instance used to process requests.
      def prototype
        @prototype ||= new
      end

      def call(env)
        synchronize { prototype.call(env) }
      end
    end
    
    include Router
    
    def call(env)
      dup.call!(env)
    end

    def call!(env)
      @env = env
      @context = Context.new(env)
    end
  end
end
