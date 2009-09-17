require 'eventmachine'
require 'em/protocols/smtpserver'

class SmtpMachine < EventMachine::Protocols::SmtpServer
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

EventMachine.run {
  EventMachine.start_server "127.0.0.1", 2525, SmtpMachine
}

