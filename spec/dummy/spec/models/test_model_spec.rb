require 'rails_helper'

RSpec.describe TestModel, type: :model do
  it do
    TestModel.create!
  end

  it do
    expect(ARQLogger.log {
      TestModel.create!
    }.count).to eq(1)
  end

  it do
    expect(ARQLogger.log {
      TestModel.create!
      TestModel.create!
    }.count).to eq(2)
  end

  context 'with associations' do
    before :all do
      10.times {
        TestChildModel.create!(test_model: TestModel.create!, name: SecureRandom.hex(4))
      }
    end

    after :all do
      TestModel.destroy_all
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
  end
end
