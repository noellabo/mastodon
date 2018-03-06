PixivApi.configure do |config|
  omniauth = Devise.omniauth_configs[:pixiv]
  strategy = omniauth.strategy_class.new(nil, *omniauth.args)

  config[:client_id] = strategy.client.id
  config[:client_secret] = strategy.client.secret
  config[:site] = strategy.client.site
  config[:authorize_url] = strategy.client.authorize_url
  config[:token_url] = strategy.client.token_url
  config[:user_agent] = 'pawoo'
end
