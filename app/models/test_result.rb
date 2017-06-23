class TestResult < ActiveRecord::Base
  attr_accessible :choice_id, :labela_id, :labelb_id, :test_id
  belongs_to :test
end
