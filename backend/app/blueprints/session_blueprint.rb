class SessionBlueprint < Blueprinter::Base
  field :access_token do |_user, options|
    options.fetch(:access_token)
  end

  field :token_type do
    "Bearer"
  end

  field :expires_in do |_user, options|
    options.fetch(:expires_in)
  end

  field :user do |user, _options|
    UserBlueprint.render_as_hash(user)
  end
end