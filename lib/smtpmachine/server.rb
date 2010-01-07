require 'em/protocols/smtpserver'

module SMTPMachine 
  class Server < EventMachine::Protocols::SmtpServer
    attr_reader :recipients, :sender
    self.parms = { :verbose => false }

    def self.base=(base)
      @@base = base
    end

    def self.base
      @@base
    end

    def receive_transaction
      @app ||= self.class.base.new
    end
    
    def receive_ehlo_domain(domain)
      @app ||= self.class.base.new
      @app.receive_ehlo(domain)
    end
    
    def receive_sender(sender)
      @app.receive_sender(sender)
    end

    def receive_recipient(recipient)
      @app.receive_recipient(recipient)
    end

    def receive_message
      @@parms[:verbose] and $>.puts "Received message"
      @@parms[:verbose] and $>.puts @data.join("\n")

      

      # df = EventMachine::DefaultDeferrable.new
      # def df.do_work
      #   succeed
      # end
      # # df.callback { $>.puts "done callbacking" }
      # # df.errback { $>.puts "ERRORZ" }
      
      
      # # EM::Deferrable.future(df) { $>.puts "done callbacking with future" }
      # # 
      # EM.defer { df.do_work }
      # # 
      # df
      @app.receive_data(@data)
    end
    
    def receive_data_chunk(data)
      @data ||= []
      @data.concat data
    end
    
    def self.start!(base)
      self.base = base

      EventMachine.run {
        EventMachine.start_server base.host, base.port, SMTPMachine::Server
      }
    end
  end
end
