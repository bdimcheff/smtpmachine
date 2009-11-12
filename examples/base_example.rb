require 'example_helper'

def call_all
  
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

    it "doesn't execute blocks from further actions" do
      called = false

      base = create_base do
        mail_from(/example.org/) { called = true }
      end

      data = {
        :action => :ehlo, 
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
    
    it "accepts multiple RCPT TOs" do
      called = 0
      
      data = {
        :action => :rcpt_to, 
        :ehlo => 'mail.example.org', 
        :mail_from => 'bar@example.org',
        :rcpt_to => 'foo@example.org'
      }

      base = create_base do
        rcpt_to(/example.org/) { called += 1 }
      end
      
      obj = base.new
      obj.call(data)
      
      data = {
        :action => :rcpt_to, 
        :rcpt_to => 'baz@example.org'
      }
      
      obj.call(data)
      
      called.should == 2
      
      obj.context.recipients.should == ["foo@example.org", "baz@example.org"]
    end
  end

  describe "data" do
    it "calls the data black when receiving a DATA action" do
      called = false
      
      base = create_base do
        data(/mail data/i) { called = true }
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

  describe "event chaining" do    
    it 'maintains state between multiple calls' do
      base = create_base do
        ehlo(/mail.example.org/) { true }
        mail_from(/bar@example.org/) { true }
      end
      
      ehlo = {
        :action => :ehlo, 
        :ehlo => 'mail.example.org', 
      }
      
      mail_from = {
        :action => :mail_from, 
        :mail_from => 'bar@example.org', 
      }
      
      server = base.new
      server.call(ehlo)
      server.call(mail_from)
      
      env = {
        :action => :mail_from, 
        :ehlo => 'mail.example.org', 
        :mail_from => 'bar@example.org', 
      }
      
      server.context.to_hash.should == env
    end
  end
  
  describe "accepted addresses" do
    
    before(:each) do
      @data = {
        :action => :data, 
        :ehlo => 'mail.example.org', 
        :mail_from => 'bar@example.org', 
        :rcpt_to => 'foo@example.org', 
        :data => 'Mail data here...'
      }
    end
    
    it "accepts the email at RCPT TO if there are matching addresses" do
      base = create_base do
        rcpt_to(/foo@example.org/) { true }
      end
      
      base.new.call(@data.merge(:action => :rcpt_to)).should be_true
    end
    
    it "rejects the email at RCPT TO if there are no matching addresses" do
      base = create_base do
        rcpt_to(/bademail/) { true }
      end
      
      base.new.call(@data.merge(:action => :rcpt_to)).should be_false
    end
    
    it "rejects the email at RCPT TO if there is a matching address that has a false block" do
      base = create_base do
        rcpt_to(/foo@example.org/) { false }
      end
      
      base.new.call(@data.merge(:action => :rcpt_to)).should be_false
    end
    
    it "rejects the email at RCPT TO even if it was accepted in MAIL FROM" do
      base = create_base do
        mail_from(/bar@example.org/) { true }
        rcpt_to(/foo@example.org/) { reject }
      end
      
      base.new.call(@data.merge(:action => :rcpt_to)).should be_false
    end
  end    
end
