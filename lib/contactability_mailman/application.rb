module ContactabilityMailman
  # The main application class. Pass a block to {#new} to create a new app.
  class Application

    def self.run(&block)
      app = new(&block)
      app.run
      app
    end

    # @return [Router] the app's router
    attr_reader :router

    # @return [MessageProcessor] the app's message processor
    attr_reader :processor

    # Creates a new router, and sets up any routes passed in the block.
    # @param [Hash] options the application options
    # @option options [true,false] :graceful_death catch interrupt signal and don't die until end of poll
    # @param [Proc] block a block with routes
    def initialize(&block)
      @router = ContactabilityMailman::Router.new
      @processor = MessageProcessor.new(:router => @router)
      instance_eval(&block)
    end

    def polling?
      ContactabilityMailman.config.poll_interval > 0 && !@polling_interrupt
    end

    # Sets the block to run if no routes match a message.
    def default(&block)
      @router.default_block = block
    end

    # Runs the application.
    def run
      ContactabilityMailman.logger.info "ContactabilityMailman v#{ContactabilityMailman::VERSION} started"

      rails_env = File.join(ContactabilityMailman.config.rails_root, 'config', 'environment.rb')
      if ContactabilityMailman.config.rails_root && File.exist?(rails_env) && !(defined?(Rails) && Rails.env)
        ContactabilityMailman.logger.info "Rails root found in #{ContactabilityMailman.config.rails_root}, requiring environment..."
        require rails_env
      end

      if ContactabilityMailman.config.graceful_death
        # When user presses CTRL-C, finish processing current message before exiting
        Signal.trap("INT") { @polling_interrupt = true }
      end

      # STDIN
      if !ContactabilityMailman.config.ignore_stdin && $stdin.fcntl(Fcntl::F_GETFL, 0) == 0
        ContactabilityMailman.logger.debug "Processing message from STDIN."
        @processor.process($stdin.read)

      # IMAP
      elsif ContactabilityMailman.config.imap
        options = {:processor => @processor}.merge(ContactabilityMailman.config.imap)
        ContactabilityMailman.logger.info "IMAP receiver enabled (#{options[:username]}@#{options[:server]})."
        polling_loop Receiver::IMAP.new(options)

      # POP3
      elsif ContactabilityMailman.config.pop3
        options = {:processor => @processor}.merge(ContactabilityMailman.config.pop3)
        ContactabilityMailman.logger.info "POP3 receiver enabled (#{options[:username]}@#{options[:server]})."
        polling_loop Receiver::POP3.new(options)

      # Maildir
      elsif ContactabilityMailman.config.maildir
        require 'maildir'

        ContactabilityMailman.logger.info "Maildir receiver enabled (#{ContactabilityMailman.config.maildir})."
        @maildir = Maildir.new(ContactabilityMailman.config.maildir)

        process_maildir

        if ContactabilityMailman.config.watch_maildir
          require 'listen'
          ContactabilityMailman.logger.debug "Monitoring the Maildir for new messages..."

          callback = Proc.new do |modified, added, removed|
            process_maildir
          end

          @listener = Listen.to(File.join(ContactabilityMailman.config.maildir, 'new')).change(&callback)
          @listener.start
        end
      end
    end

    # List all message in Maildir new directory and process it
    def process_maildir
      # Process messages queued in the new directory
      ContactabilityMailman.logger.debug "Processing new message queue..."
      @maildir.list(:new).each do |message|
        @processor.process_maildir_message(message)
      end
    end

    private

    # Run the polling loop for the email inbox connection
    def polling_loop(connection)
      if polling?
        polling_msg = "Polling enabled. Checking every #{ContactabilityMailman.config.poll_interval} seconds."
      else
        polling_msg = "Polling disabled. Checking for messages once."
      end
      ContactabilityMailman.logger.info(polling_msg)

      loop do
        begin
          connection.connect
          connection.get_messages
          connection.disconnect
        rescue SystemCallError => e
          ContactabilityMailman.logger.error e.message
        end

        break unless polling?
        sleep ContactabilityMailman.config.poll_interval
      end
    end

  end
end
