require 'em/protocols/smtpserver'

module SMTPMachine 
  class Server < EventMachine::Protocols::SmtpServer
    attr_reader :recipients, :sender
    self.parms = { :verbose => true }
    
    def receive_sender(sender)
      @sender = sender
      
      true
    end

    def receive_recipient(recipient)
      @recipients ||= []
      @recipients << recipient
      
      @@parms[:verbose] and $>.puts "Received recicipent #{recipient}"

      true
    end

    def receive_message
      @@parms[:verbose] and $>.puts "Received message"
      @@parms[:verbose] and $>.puts @data.join("\n")
      
      df = EventMachine::DefaultDeferrable.new
      def df.do_work 
        $>.puts "doing work"
        sleep 2
        $>.puts "done waiting"
        succeed
      end
      # df.callback { $>.puts "done callbacking" }
      # df.errback { $>.puts "ERRORZ" }
      
      
      EM::Deferrable.future(df) { $>.puts "done callbacking with future" }
      
      EM.defer { df.do_work }
      
      df
    end
    
    def receive_data_chunk(data)
      @data ||= []
      @data.concat data
    end
    
    def self.start!
      EventMachine.run {
        EventMachine.start_server "127.0.0.1", 2525, SMTPMachine::Server
      }
    end
  end
end
