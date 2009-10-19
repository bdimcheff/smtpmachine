require 'example_helper'

describe 'SMTPMachine::Context' do
  it "handles ehlo" do
    env = {:action => :ehlo, :ehlo => 'example.com'}

    context = Context.new(env)

    context.ehlo?.should be_true
    context.ehlo.should == 'example.com'
    context.data.should be_nil
  end

  it "returns a tmail" do
    env = { :action => :data, 
      :ehlo => 'mail.example.org', 
      :mail_from => 'foo@example.org', 
      :rcpt_to => 'bar@example.org', 
      :data => email_fixture('rack_ann') }

    context = Context.new(env)

    context.to_tmail.should be_kind_of(TMail::Mail)
  end
end
