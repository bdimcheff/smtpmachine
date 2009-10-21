require 'example_helper'

def call_all
  
end

def create_base(&block)
  base = Class.new(SMTPMachine::Base)
  base.class_eval(&block)
  base
end

describe "SMTPMachine::Base" do
  describe "ehlo" do
    it "calls the ehlo block when receiving an EHLO action" do
      called = false

      base = create_base do
        ehlo(/example.org/) { called = true }
      end

      data = {
        :action => :ehlo, 
        :ehlo => 'mail.example.org'
      }

      base.new.call(data)

      called.should be_true
    end

    it "doesn't execute the block for other actions" do
      called = false

      base = create_base do
        ehlo(/example.org/) { called = true }
      end

      data = {
        :action => :mail_from, 
        :ehlo => 'mail.example.org'
      }

      base.new.call(data)
      called.should be_false
    end
  end

  describe "mail_from" do
    it "calls the mail_from block when receiving a MAIL FROM action" do
      called = false
      
      data = {
        :action => :mail_from, 
        :ehlo => 'mail.example.org', 
        :mail_from => 'bar@example.org'
      }

      base = create_base do
        mail_from(/bar@example.org/) { called = true }
      end
      
      base.new.call(data)
      called.should be_true
    end
  end

  describe "rcpt_to" do
    it "calls the rcpt_to block when receiving a RCPT TO action" do
      called = false
      
      data = {
        :action => :rcpt_to, 
        :ehlo => 'mail.example.org', 
        :mail_from => 'bar@example.org',
        :rcpt_to => 'foo@example.org'
      }

      base = create_base do
        rcpt_to(/foo@example.org/) { called = true }
      end
      
      base.new.call(data)
      called.should be_true
    end
  end

  describe "map" do
    it "calls the block during data phase when rcpt_to matches the regex" do
      called = false
      
      base = create_base do
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
end
