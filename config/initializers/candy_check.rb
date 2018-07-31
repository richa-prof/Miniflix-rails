if Rails.env.production?
  config = CandyCheck::AppStore::Config.new(
    environment: :production
  )
else
  config = CandyCheck::AppStore::Config.new(
    environment: :sandbox
  )
end

CANDY_CHECK_VERIFIER = CandyCheck::AppStore::Verifier.new(config)
