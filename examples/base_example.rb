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

      base.new.receive_ehlo('example.org')

      called.should be_true
    end

    it "doesn't execute blocks from further actions" do
      called = false

      base = create_base do
        mail_from(/example.org/) { called = true }
      end

      base.new.receive_ehlo('example.org')
      called.should be_false
    end
  end

  describe "mail_from" do
    it "calls the mail_from block when receiving a MAIL FROM action" do
      called = false
      
      base = create_base do
        mail_from(/bar@example.org/) { called = true }
      end
      
      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('bar@example.org')
      
      called.should be_true
    end
  end

  describe "rcpt_to" do
    it "calls the rcpt_to block when receiving a RCPT TO action" do
      called = false
      
      base = create_base do
        rcpt_to(/foo@example.org/) { called = true }
      end
      
      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('bar@example.org')
      app.receive_recipient('foo@example.org')

      called.should be_true
    end
    
    it "accepts multiple RCPT TOs" do
      called = 0
      
      base = create_base do
        rcpt_to(/example.org/) { called += 1 }
      end
      
      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('bar@example.org')
      app.receive_recipient('foo@example.org')
      app.receive_recipient('baz@example.org')
      
      called.should == 2
      
      app.context.to.should == ["foo@example.org", "baz@example.org"]
    end
  end

  describe "data" do
    it "calls the data black when receiving a DATA action" do
      called = false
      
      base = create_base do
        data(/mail data/i) { called = true }
      end

      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('bar@example.org')
      app.receive_recipient('foo@example.org')
      app.receive_data('Mail data goes here...')

      called.should be_true
    end
  end


  describe "map" do
    it "calls the block during data phase when rcpt_to matches the regex" do
      called = false
      
      base = create_base do
        map(/foo@example.org/) { called = true }
      end

      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('bar@example.org')
      app.receive_recipient('foo@example.org')
      
      called.should be_false
      
      app.receive_data('Mail data here...')

      called.should be_true
    end
  end

  describe "event chaining" do    
    it 'rejects subsequent recipients even if a previous match succeded' do
      called = 0
      
      base = create_base do
        rcpt_to(/foo@example.org/) { called += 1 }
      end
      
      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('sender@example.org')
      app.receive_recipient('foo@example.org')
      app.receive_recipient('bar@example.org')
      
      called.should == 1
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
      
      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('sender@example.org')
      app.receive_recipient('foo@example.org').should be_true
    end
    
    it "rejects the email at RCPT TO if there are no matching addresses" do
      base = create_base do
        rcpt_to(/bademail/) { true }
      end
      
      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('sender@example.org')
      app.receive_recipient('foo@example.org').should be_false
    end
    
    it "rejects the email at RCPT TO if there is a matching address that has a false block" do
      base = create_base do
        rcpt_to(/foo@example.org/) { false }
      end
      
      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('sender@example.org')
      app.receive_recipient('foo@example.org').should be_false
    end
    
    it "rejects the email at RCPT TO even if it was accepted in MAIL FROM" do
      base = create_base do
        mail_from(/bar@example.org/) { true }
        rcpt_to(/foo@example.org/) { reject }
      end
      
      app = base.new
      app.receive_ehlo('mail.example.org')
      app.receive_sender('sender@example.org')
      app.receive_recipient('foo@example.org').should be_false
    end
  end  
  
  describe 'a simple complete SMTP app' do
    it 'accepts an email with a particular recipient' do
      base = create_base do
        ehlo(/example/) { true }
        mail_from(/example/) { true }
        rcpt_to(/foo@example.org/) { true }
        data { true }
      end
      
      app = base.new
      app.receive_ehlo('mail.example.org').should be_true
      app.receive_sender('sender@example.org').should be_true
      app.receive_recipient('foo@example.org').should be_true
      app.receive_data('Some Mail Data').should be_true
    end
  end
end
