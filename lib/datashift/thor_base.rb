# Copyright:: (c) Autotelik Media Ltd 2012
# Author ::   Tom Statter
# License::   MIT.
#
require 'thor'

module DataShift

  class DSThorBase < Thor

    include DataShift::Logging

    no_commands do
      def start_connections

        # TODO: - We're assuming run from a rails app/top level dir...

        if File.exist?(File.expand_path('config/environment.rb'))
          begin
            require File.expand_path('config/environment.rb')
          rescue => e
            logger.error("Failed to initialise ActiveRecord : #{e.message}")
            raise ConnectionError.new("Failed to initialise ActiveRecord : #{e.message}")
          end

        else
          raise PathError.new('No config/environment.rb found - cannot initialise ActiveRecord')
          # TODO: make this more robust ? e.g what about when using active record but not in Rails app, Sinatra etc
        end
      end
    end

  end

end
