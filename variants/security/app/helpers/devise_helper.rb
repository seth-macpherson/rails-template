module DeviseHelper
  def omniauth_class(provider)
    overrides = { google_oauth2: "google plus" }
    overrides[provider] || provider.to_s.parameterize
  end

  def omniauth_icon(provider)
    overrides = { google_oauth2: "google plus" }
    overrides[provider] || provider.to_s.parameterize
  end

  def omniauth_label(provider)
    I18n.t("devise.omniauth.#{provider}", default: provider.to_s.titleize)
  end
end
