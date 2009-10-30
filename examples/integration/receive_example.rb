require 'example_helper'

describe 'receiving SMTP messages' do  
  it 'should do stuff' do
    # server = in_server do
    #   EM::Protocols::SmtpClient.send :host=> '127.0.0.1',
    #     :port=>'2525',
    #     :domain=>"bogus",
    #     :from=>"me@example.com",
    #     :to=>"you@example.com",
    #     :header=> {"Subject"=>"Email subject line", "Reply-to"=>"me@example.com"},
    #     :body=>"Not much of interest here."
    # end
    
    # server.recipients.should == ['<you@example.com>']
    # server.sender.should == '<me@example.com>'
  end

  it "runs the server" do
    base = create_base do
      
    end
    called = false
    server = in_server(base) do
      called = true
      send_mail
    end

    called.should be_true
  end

  focused "collects the data" do
    data = nil
    
    base = create_base do
      map(/ruby-talk/) { data = self.data }
    end

    server = in_server(base) { send_fixture("rack_ann") }

    data.should == email_fixture("rack_ann")
  end
  
  # it 'should do other stuff' do
  #   puts "baz "
  # end
end
