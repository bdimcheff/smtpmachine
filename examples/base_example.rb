require 'example_helper'

def call_all
  
end

describe "SMTPMachine::Base" do
  describe "ehlo" do
    it "calls the ehlo block when receiving an EHLO action" do
      called = false

      base = Class.new(SMTPMachine::Base)
      base.class_eval do
        ehlo(/example.org/) { called = true }
      end

      data = {
        :action => :ehlo, 
        :ehlo => 'mail.example.org'
      }

      base.new.call(data)

      called.should be_true
    end
    
  end
  
  it "calls the block when an email is received for a matching address" do
    called = false
    
    base = Class.new(SMTPMachine::Base)
    base.class_eval do
      map(/foo@example.org/) { called = true }
    end

    data = {
      :action => :data, 
      :ehlo => 'mail.example.org', 
      :mail_from => 'bar@example.org', 
      :rcpt_to => 'foo@example.org', 
      :data => 'Mail data here...'
    }
    
    base.new.call(data)

    called.should be_true
  end
end
