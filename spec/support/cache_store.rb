RSpec.configure do |config|
  config.before(:example, disable_cache: true) do
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::NullStore.new)
  end

  config.after(:example, disable_cache: true) do
    allow(Rails).to receive(:cache).and_call_original
  end
end
