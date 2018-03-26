# frozen_string_literal: true

module Pawoo::SlaveReader
  def read_from_slave
    SwitchPoint.with_readonly(:pawoo_slave) { yield }
  end
end
