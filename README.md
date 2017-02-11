# ARQLogger

This is ActiveRecord Query Logger.

This gem logs count of query and duration of only querying.

# Installation

```ruby
gem 'a_r_q_logger'
```

or

```ruby
gem 'a_r_q_logger', require: false

require 'a_r_q_logger'
```

# Usage

## In tests

## count queries

```ruby
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

## count instantiating

```ruby
before :all do
  10.times {
    TestChildModel.create!(test_model: TestModel.create!, name: SecureRandom.hex(4))
  }
end

it do
  expect(ARQLogger.log {
    TestModel.includes(:test_child_models).load
  }.instances).to eq(20)
end

it do
  expect(ARQLogger.log {
    TestModel.joins(:test_child_models).select('test_child_models.id as as_id').load
  }.instances).to eq(10)
end
```


## In Anywhere

```
pry(main)> ARQLogger.log { 3.times { TestModel.has_children(10).map(&:children_count) } } 
=> #<struct ARQLogger::Result count=3, msec=1508.4>
```