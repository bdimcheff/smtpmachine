require 'tmail'
require 'state_machine'

class Context
  attr_accessor :ehlo, :from, :to, :data
  
  state_machine do
    event :receive_ehlo do
      transition nil => :authenticated
    end
    
    before_transition :on => :receive_ehlo do |context, transition|
      context.ehlo = transition.args.shift
    end
    
    event :receive_sender do
      transition :authenticated => :received_sender
    end
        
    before_transition :on => :receive_sender do |context, transition|
      context.from = transition.args.shift
    end
    
    event :receive_recipient do
      transition [:received_sender, :received_recipients] => :received_recipients
    end
    
    before_transition :on => :receive_recipient do |context, transition|
      context.add_recipient transition.args.shift
    end
    
    event :receive_data do
      transition :received_recipients => :received_data
    end
    
    before_transition :on => :receive_data do |context, transition|
      context.data = transition.args.shift
    end
  end
  
  def initialize
    @to = []
  end
  
  def add_recipient(recipient)
    @to << recipient
  end
  
  def to_tmail
    TMail::Mail.parse(data) if received_data?
  end
  # 
  # def to_hash
  #   h = env.dup
  #   h.merge!(:rcpt_to => @recipients) unless @recipients.empty?
  #   h
  # end
end
