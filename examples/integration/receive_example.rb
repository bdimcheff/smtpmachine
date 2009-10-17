require 'example_helper'

describe 'receiving SMTP messages' do  
  it 'should do stuff' do
    server = in_server do
      EM::Protocols::SmtpClient.send :host=> '127.0.0.1',
        :port=>'2525',
        :domain=>"bogus",
        :from=>"me@example.com",
        :to=>"you@example.com",
        :header=> {"Subject"=>"Email subject line", "Reply-to"=>"me@example.com"},
        :body=>"Not much of interest here."
    end
    
    server.recipients.should == ['<you@example.com>']
    server.sender.should == '<me@example.com>'
  end
  
  # it 'should do other stuff' do
  #   puts "baz "
  # end
end