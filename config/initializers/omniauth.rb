OmniAuth.configure do |config|
  config.before_request_phase = ->(env) {
    Pawoo::FollowController.action(:queue).call(env)
  }
end
