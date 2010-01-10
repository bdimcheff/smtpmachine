describe "SMTPMachine Options" do
  before(:each) do
    @base = SMTPMachine::Base
  end
  
  describe 'host' do
    it 'defaults to 0.0.0.0' do
      @base.host.should == '0.0.0.0'
    end
  end

  describe 'port' do
    it 'defaults to 25' do
      @base.port.should == 25
    end
  end
end