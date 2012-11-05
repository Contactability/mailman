require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe ContactabilityMailman::Application do

  describe 'instance variables' do

    before do
      @app = ContactabilityMailman::Application.new {}
    end

    it 'should initialize and store the router' do
      @app.router.class.should == ContactabilityMailman::Router
    end

    it 'should initialize and store the message processor' do
      @app.processor.class.should == ContactabilityMailman::MessageProcessor
    end

  end

  describe "#run" do
    describe "when graceful_death flag is set" do
      before do
        ContactabilityMailman.config.graceful_death = true
        ContactabilityMailman.config.poll_interval = 0.1
        @app = ContactabilityMailman::Application.new {}
      end

      it "should catch interrupt signal and let a POP3 receiver finish its poll before exiting" do
        @mock_receiver = double("Receiver::POP3")
        @mock_receiver.stub(:connect)
        @mock_receiver.stub(:get_messages) {Process.kill("INT", $$)}
        @mock_receiver.should_receive(:disconnect).at_most(:twice)
        ContactabilityMailman::Receiver::POP3.stub(:new) {@mock_receiver}

        ContactabilityMailman.config.pop3 = {}

        Signal.trap("INT") {raise "Application didn't catch SIGINT"}
        @app.run
      end
    end
  end
end
