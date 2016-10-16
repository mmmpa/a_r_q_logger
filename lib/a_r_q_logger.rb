require 'a_r_q_logger/initializer'

module ARQLogger
  class << self
    attr_accessor :store

    def pass(event)
      return unless store

      payload = event.payload
      if payload[:name] && !ActiveRecord::LogSubscriber::IGNORE_PAYLOAD_NAMES.include?(payload[:name])
        store.push(event.duration)
      end
    end

    def log(&block)
      start
      block.call
      finish
    end

    private

    def start
      self.store = []
    end

    def finish
      logged = store
      self.store = nil

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
