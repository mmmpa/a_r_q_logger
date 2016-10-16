module ARQLogger
  module Initializer
    def self.patch
      class_eval <<-EOS
        class ActiveRecord::LogSubscriber
          alias_method :real_sql, :sql

          def sql(event)
            ARQLogger.pass(event)
            real_sql(event)
          end
        end
      EOS
    end
  end
end

if defined?(ActiveRecord::LogSubscriber)
  ARQLogger::Initializer.patch
else
  class ARQLoggerApplicationProxy < ::Rails::Railtie
    initializer('add pass method') { ARQLogger::Initializer.patch }
  end
end
