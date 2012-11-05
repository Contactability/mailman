module ContactabilityMailman
  module Receiver

    autoload :POP3, 'contactability_mailman/receiver/pop3'
    autoload :IMAP, 'contactability_mailman/receiver/imap'

  end
end