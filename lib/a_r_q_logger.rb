require 'a_r_q_logger/initializer'
require 'monitor'

# Thread.current.object_id

module ARQLogger
  cattr_accessor :store, :mon

  self.store = {}
  self.mon = Monitor.new

  class << self
    def sql(event)
      return unless store

      payload = event.payload
      if payload[:name] && !ActiveRecord::LogSubscriber::IGNORE_PAYLOAD_NAMES.include?(payload[:name])
        mon.synchronize { store[key].push(event.duration) }
      end
    end

    def instantiate
      mon.synchronize { store[key] && store[key].instantiate }
    end

    def log(&block)
      start
      block.call
      finish
    end

    private

    def start
      mon.synchronize do
        raise CannotNestedStarting if store[key]

        store[key] = Log.new
      end
    end

    def finish
      mon.synchronize do
        store.delete(key).tap do |result|
          result.finish
        end
      end
    end

    def key
      Thread.current.object_id
    end
  end

  class Log
    attr_accessor :start_at, :queries, :duration, :instances

    def initialize(start_at: Time.now.to_i)
      @start_at = start_at

      @queries = []
      @instances = 0
    end

    def finish(end_at: Time.now.to_i)
      @duration = end_at - start_at
    end

    def instantiate
      @instances += 1
    end

    def push(query)
      @queries.push(query)
    end

    def count
      @queries.size
    end

    def queries_time
      @queries.sum.round(1)
    end
  end

  class CannotNestedStarting < StandardError
  end
end
