class TestModel < ActiveRecord::Base
  has_many :test_child_models, dependent: :destroy
end
