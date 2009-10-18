module SMTPMachine
  module Router
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
    
    module ClassMethods
      attr_reader :routes

      def map(regex, options = {}, &block)
        define_method "__email #{regex}", &block
        unbound_method = instance_method("__email #{regex}")

        block = lambda { unbound_method.bind(self).call }
        
        @routes ||= []
        @routes.push([regex, block]).last
      end
    end

    attr_accessor :routes
      
    def route!(email)
      compile_routes(email) unless routes
      
      catch(:halt) do
        routes.each do |block|
          catch(:pass) do
            instance_eval(&block)
          end
        end
      end
    end

    private
    def compile_routes(email)
      self.routes = self.class.routes.select {|r, _| r =~ email}.map {|_,b| b}
    end

    # Pass control to the next matching route.
    def pass
      throw :pass
    end
    
    # Exit the current block, halts any further processing of the request
    def halt
      throw :halt
    end
  end
end
