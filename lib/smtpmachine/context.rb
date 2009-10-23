require 'tmail'

class Context
  attr_reader :env, :recipients

  def initialize(env = {})
    @env = {}
    @recipients = []
    
    add(env)
  end

  def action
    @env[:action]
  end

  [:ehlo, :mail_from, :rcpt_to, :data].each do |a|
    define_method("#{a}")  { @env[a] }
    define_method("#{a}?") { a == action }
  end
  
  def add(env)
    self.env.merge!(env)
    self.recipients.concat([rcpt_to].flatten.uniq) if rcpt_to?
  end

  def to_tmail
    TMail::Mail.parse(data) if data?
  end
  
  def to_hash
    h = env.dup
    h.merge!(:rcpt_to => @recipients) unless @recipients.empty?
    h
  end
end
