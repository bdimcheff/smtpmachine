require 'tmail'

class Context
  attr_reader :ehlo, :from, :to, :data
    
  def receive_ehlo(ehlo)
    @ehlo = ehlo
  end
  
  def receive_sender(sender)
    @from = sender
  end
  
  def receive_recipient(recipient)
    @to << recipient
  end
  
  def receive_data(data)
    @data = data
  end
  
  def initialize
    super
    @to = []
  end
  
  def add_recipient(recipient)
    @to << recipient
  end
  
  def to_tmail
    TMail::Mail.parse(data) if data
  end
end
