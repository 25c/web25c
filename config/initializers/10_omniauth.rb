Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GOOGLE_SETTINGS[:client_id], GOOGLE_SETTINGS[:client_secret], { 
    access_type: 'offline', 
    approval_prompt: '',  
    scope: 'https://www.googleapis.com/auth/userinfo.profile,https://www.googleapis.com/auth/userinfo.email'
  }
  provider :twitter, TWITTER_SETTINGS[:consumer_key], TWITTER_SETTINGS[:consumer_secret]
end