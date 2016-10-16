# ARQLogger

This is ActiveRecord Query Logger.

This gem logs count of query and duration of only querying.

# Installation

```
gem 'a_r_q_logger'
```

or

```
gem 'a_r_q_logger', require: false

require 'a_r_q_logger'
```

# Usage

## In tests

```
before :all do
  10.times {
    TestChildModel.create!(test_model: TestModel.create!, name: SecureRandom.hex(4))
  }
end

it do
  expect(ARQLogger.log {
    TestModel.includes(:test_child_models).all.each { |m| m.test_child_models.map(&:name) }
  }.count).to eq(2)
end

it do
  expect(ARQLogger.log {
    TestModel.all.each { |m| m.test_child_models.map(&:name) }
  }.count).to eq(11)
end
```

## In Anywhere

```
pry(main)> ARQLogger.log { 3.times { TestModel.has_children(10).map(&:children_count) } } 
=> #<struct ARQLogger::Result count=3, msec=1508.4>
```