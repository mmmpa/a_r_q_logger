module ARQLogger
  class << self
    def log(&block)
      start
      block.call
      finish
    end

    private

    def start
      ActiveRecord::LogSubscriber.duration_store_box = []
    end

    def finish
      logged = ActiveRecord::LogSubscriber.duration_store_box
      ActiveRecord::LogSubscriber.duration_store_box = nil

      Result.new(
        count: logged.size,
        msec: logged.sum.round(1)
      )
    end
  end

  class Result < Struct.new(:count, :msec)
    def initialize(count:, msec:)
      super(count, msec)
    end
  end
end

class ARQLoggerApplicationProxy < ::Rails::Railtie
  initializer 'set data store for ARQLogger' do
    class ::ActiveRecord::LogSubscriber
      cattr_accessor :duration_store_box

      alias_method :real_sql, :sql

      def sql(event)
        payload = event.payload
        if payload[:name] && !IGNORE_PAYLOAD_NAMES.include?(payload[:name])
          self.class.duration_store_box.push(event.duration) if self.class.duration_store_box
        end
        real_sql(event)
      end
    end
  end
end