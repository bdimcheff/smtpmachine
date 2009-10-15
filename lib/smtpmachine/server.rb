require 'em/protocols/smtpserver'

module SMTPMachine 
  class Server < EventMachine::Protocols::SmtpServer
    self.parms = { :verbose => true }

    def receive_recipient(recipient)
      @recipients ||= []
      @recipients << recipient

      true
    end

    def receive_message
      puts @recipients.join(",")
      true
    end
  end
end
