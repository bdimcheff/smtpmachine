module SMTPMachine
  module Router
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
    
    module ClassMethods
      attr_accessor :routes

      def reset!
        self.routes = {}
      end

      def ehlo(regex, options = {}, &block)
        add_route(:ehlo, regex, options, &block)
      end

      def map(regex, options = {}, &block)
        add_route(:data, regex, ({:match => :rcpt_to}).merge(options), &block)
      end

      def add_route(action, regex, options = {}, &block)
        match_against = options[:match] || action
        define_method "__email #{action} #{regex}", &block
        unbound_method = instance_method("__email #{action} #{regex}")

        block = lambda { unbound_method.bind(self).call }

        (routes[action] ||= []).
          push([regex, match_against, block]).last
      end
    end

    attr_accessor :routes

    def initialize
      self.routes = {}
      super
    end
      
    def route!
      compile_routes

      catch(:halt) do
        routes.each do |block|
          catch(:pass) do
            instance_eval(&block)
          end
        end
      end
    end

    private
    def compile_routes
      self.routes =
        (self.class.routes[context.action] || []).select { |r, m, _|
        r ? r =~ context.send(m) : true  #TODO security wrt. send
      }.map {|_,_,b| b}
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
