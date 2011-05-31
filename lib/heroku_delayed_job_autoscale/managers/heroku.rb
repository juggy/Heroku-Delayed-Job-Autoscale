require 'heroku'


module HerokuDelayedJobAutoscale
  module Manager
    class Heroku
      def initialize(options={})
        begin
          username = options[:username] || ENV['HEROKU_USERNAME']
          password = options[:password] || ENV['HEROKU_PASSWORD']
          @app     = options[:app]      || ENV['HEROKU_APP']
          @client = ::Heroku::Client.new(username, password)
        rescue => e
          begin
            require 'hoptoad_notifier'
            notify_hoptoad(e)
          end
          Rails.logger.error e
        end
      end

      def qty
        begin
          @client.info(@app)[:workers].to_i
        rescue => e
          notify_hoptoad(e) if hoptoad_loaded
          Rails.logger.error e
        end
      end

      def scale_up
        begin
          @client.set_workers(@app, 1)
        rescue => e
          begin
            require 'hoptoad_notifier'
            notify_hoptoad(e)
          end
          Rails.logger.error e
        end
      end

      def scale_down
        begin
          @client.set_workers(@app, 0)
        rescue => e
          begin
            require 'hoptoad_notifier'
            notify_hoptoad(e)
          end
          Rails.logger.error e
        end
      end
    end
  end
end