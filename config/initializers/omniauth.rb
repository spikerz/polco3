Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['OMNIAUTH_PROVIDER_KEY'], ENV['OMNIAUTH_PROVIDER_SECRET']
  # https://dev.twitter.com/apps/3670983/oauth
  provider :identity
end
