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

      def ehlo(regex = nil, options = {}, &block)
        add_route(:ehlo, regex, options, &block)
      end

      def mail_from(regex = nil, options = {}, &block)
        add_route(:from, regex, options, &block)
      end
      
      def rcpt_to(regex = nil, options = {}, &block)
        add_route(:to, regex, options, &block)
      end
      
      def data(regex = nil, options = {}, &block)
        add_route(:data, regex, options, &block)
      end

      def map(regex = nil, options = {}, &block)
        add_route(:to, regex) { true }
        add_route(:data, regex, ({:match => :to}).merge(options), &block)
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
      super
      self.routes = {}
    end
      
    def route!
      compile_routes
      match = false
      
      routes.each do |block|
        catch(:pass) do
          res = instance_eval(&block)
          match ||= res
        end
      end
      match
    end

    private
    def compile_routes
      self.routes =
        (self.class.routes[action] || []).select do |regex, match_action, _|
          if !regex
            true
          elsif action == match_action
            regex =~ payload
          else
            !([context.send(match_action)].flatten.grep(regex)).empty?
          end
      end.map {|_,_,b| b}
    end

    # Pass control to the next matching route.
    def pass
      throw :pass
    end
    
    # Exit the current block, halts any further processing of the request
    def halt
      throw :halt
    end
    
    # Rejects the email immediately
    def reject
      throw :halt, false
    end
  end
end
