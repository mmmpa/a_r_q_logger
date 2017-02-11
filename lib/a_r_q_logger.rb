require 'a_r_q_logger/initializer'

module ARQLogger
  class << self
    attr_accessor :store, :instantiating

    def pass(event)
      return unless store

      payload = event.payload
      if payload[:name] && !ActiveRecord::LogSubscriber::IGNORE_PAYLOAD_NAMES.include?(payload[:name])
        store.push(event.duration)
      end
    end

    def instantiate
      self.instantiating += 1 if instantiating
    end

    def log(&block)
      start
      block.call
      finish
    end

    private

    def start
      self.store = []
      self.instantiating = 0
    end

    def finish
      logged = store
      instances = instantiating

      self.store = nil
      self.instantiating = nil

      Result.new(
        count: logged.size,
        msec: logged.sum.round(1),
        instances: instances
      )
    end
  end

  class Result < Struct.new(:count, :msec, :instances)
    def initialize(count:, msec:, instances:)
      super(count, msec, instances)
    end
  end
end
