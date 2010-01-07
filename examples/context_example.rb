require 'example_helper'

describe 'SMTPMachine::Context' do
  it "handles ehlo" do
    context = Context.new
    
    context.can_receive_ehlo?.should be_true
    context.receive_ehlo('example.com')
    context.ehlo.should == 'example.com'
  end
  
  it "handles mail from" do
    context = Context.new
    
    context.can_receive_sender?.should be_false
    context.receive_ehlo('example.com')
    context.can_receive_sender?.should be_true
    context.receive_sender('foo@example.org')
    context.from.should == 'foo@example.org'
  end
  
  it "handles rcpt to" do
    context = Context.new
    
    context.can_receive_recipient?.should be_false
    context.receive_ehlo('example.com')
    context.can_receive_recipient?.should be_false
    context.receive_sender('foo@example.org')
    context.can_receive_recipient?.should be_true
    context.receive_recipient('bar@example.org')
    context.to.should == ['bar@example.org']
  end
  
  it "handles multiple rcpt tos" do
    context = Context.new
    
    context.can_receive_recipient?.should be_false
    context.receive_ehlo('example.com')
    context.can_receive_recipient?.should be_false
    context.receive_sender('foo@example.org')
    context.can_receive_recipient?.should be_true
    context.receive_recipient('bar@example.org')
    context.can_receive_recipient?.should be_true
    context.receive_recipient('quux@example.org')
    context.to.should == ['bar@example.org', 'quux@example.org']
  end
  
  it "handles data" do
    context = Context.new
    
    context.can_receive_data?.should be_false
    context.receive_ehlo('example.com')
    context.can_receive_data?.should be_false
    context.receive_sender('foo@example.org')
    context.can_receive_data?.should be_false
    context.receive_recipient('bar@example.org')
    context.can_receive_data?.should be_true
    context.receive_data('blah')
    context.data.should == 'blah'
  end

  it "returns a tmail" do
    env = { 
      :ehlo => 'mail.example.org', 
      :from => 'foo@example.org', 
      :to => 'bar@example.org', 
      :data => email_fixture('rack_ann') 
    }

    context = build_context(env)

    context.to_tmail.should be_kind_of(TMail::Mail)
  end
end
