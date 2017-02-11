require 'active_record'
require 'supports/schema'
require 'models/test_child_model'
require 'models/test_model'
require 'tempfile'
require 'securerandom'

ActiveRecord::Base.logger = Logger.new(Tempfile.new(''))

require 'a_r_q_logger'

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

  context 'in multi thread' do
    before do
      TestModel.destroy_all
    end

    after do
      TestModel.destroy_all
    end

    it do
      threads = []

      wrap = ARQLogger.log {
        10.times do
          threads.push(Thread.start do
            ActiveRecord::Base.connection_pool.with_connection do
              sleep rand(0..2) / 10
              re = ARQLogger.log {
                TestModel.create!
                sleep rand(0..2) / 10
                TestModel.create!
                sleep rand(0..2) / 10
                TestModel.create!
              }
              expect(re.count).to eq(3)
              expect(re.instances).to eq(3)
            end
          end)
        end
      }

      threads.each { |t| t.join }

      expect(wrap.count).to eq(0)
      expect(TestModel.count).to eq(30)
    end
  end

  context 'with associations' do
    before :all do
      TestModel.delete_all
      TestChildModel.delete_all

      10.times {
        TestChildModel.create!(test_model: TestModel.create!, name: SecureRandom.hex(4))
      }
    end

    after :all do
      TestModel.destroy_all
    end

    describe 'queries' do
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

    describe 'instantiating' do
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
    end
  end
end
