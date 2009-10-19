require 'tmail'

class Context
  attr_reader :env

  def initialize(env)
    @env = env
  end

  def action
    @env[:action]
  end

  [:ehlo, :mail_from, :rcpt_to, :data].each do |a|
    define_method("#{a}")  { @env[a] }
    define_method("#{a}?") { a == action }
  end

  def to_tmail
    TMail::Mail.parse(data) if data?
  end
end
