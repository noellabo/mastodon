SwitchPoint.configure do |config|
  config.define_switch_point :pawoo_slave, readonly: :"#{Rails.env}_pawoo_slave"
end

SwitchPoint.writable_all!
