require 'example_helper'

describe 'receiving SMTP messages' do
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

  it "doesn't alter mail data sent through it" do
    data = nil
    
    base = create_base do
      ehlo(/.*/) { true }
      mail_from(/.*/) { true }
      map(/ruby-talk/) { data = self.context.data.join("\n") }
    end

    server = in_server(base) { send_fixture("rack_ann") }

    data.should == email_fixture("rack_ann")
  end
end
