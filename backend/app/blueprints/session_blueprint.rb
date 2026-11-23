class SessionBlueprint < Blueprinter::Base
  field :access_token do |_user, options|
    options.fetch(:access_token)
  end

  field :token_type do |_user, _options|
    "Bearer"
  end

  field :expires_in do |_user, options|
    options.fetch(:expires_in)
  end

  association :user, blueprint: UserBlueprint do |user, _options|
    user
  end
end
