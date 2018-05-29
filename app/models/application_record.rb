# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include Remotable
  use_switch_point(:pawoo_slave)
end
