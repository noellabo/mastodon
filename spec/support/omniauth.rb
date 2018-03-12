OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:pixiv] = OmniAuth::AuthHash.new(
  provider: 'pixiv',
  uid: '1',
  info: {
    email: 'test@pawoo.dev',
    name: 'testuser_name',
    nickname: 'testuser_account',
    id: 1,
    avatar: 'http://localhost/test.jpg'
  },
  credentials: {
    token: 'xxx',
    refresh_token: 'xxx',
    expires_at: 1.hours.since.to_i
  },
  extra: {
    raw_info: {}
  }
)
