require 'rubygems'
require 'micronaut'
require 'tmail'
require 'ruby-debug'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'smtpmachine'

def not_in_editor?
  !(ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM'))
end

Micronaut.configure do |c|
  c.color_enabled = not_in_editor?
  c.filter_run :focused => true
end

class SMTPMachine::Server
  self.parms = {}
  
  def connection_ended
    EM.stop_event_loop
  end
end

# helpers
def in_server(base)
  c = nil

  SMTPMachine::Server.base = base
  
  EventMachine.run {
    EventMachine.start_server("127.0.0.1", 2525, SMTPMachine::Server) { |conn| c = conn}
    EM::Timer.new(5) {EM.stop} # prevent hanging the test suite in case of error
    yield c
  }
  c
end

def create_base(&block)
  base = Class.new(SMTPMachine::Base)
  base.class_eval(&block)
  base
end

def email_fixture(email)
  File.read(File.expand_path(File.join(File.dirname(__FILE__), 'emails', email)))
end

def send_mail(params = {})
  defaults = {
    :host=> '127.0.0.1',
    :port=>'2525',
    :domain=>"bogus.com",
    :from=>"me@example.com",
    :to=>"you@example.com",
    :header=> {"Subject"=>"Email subject line", "Reply-to"=>"me@example.com"},
    :body=>"Not much of interest here."
  }

  EM::Protocols::SmtpClient.send(defaults.merge(params))
end

def send_fixture(email)
  mail_text = email_fixture(email)
  m = TMail::Mail.parse(mail_text)

  #send_mail(:to => m.to, :from => m.from, :body => m.body, :header =>
  #m.header)

  EM::Protocols::SmtpClient.send(:host => '127.0.0.1',
                                 :port => '2525',
                                 :domain => 'bogus.com',
                                 :from => m.from,
                                 :to => m.to,
                                 :content => mail_text + "\r\n.\r\n")
end
