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

    def route!(email)
      routes = self.class.routes

      routes.each do |regex, block|
        if regex =~ email
          instance_eval(&block)
        end
      end
    end
  end
end
