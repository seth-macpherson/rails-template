# Represents an omniauth identity. An identity consists primarily of a provider
# and a unique ID. For example 'facebook' and the user's ID on Facebook
class Identity < ApplicationRecord
  acts_as_paranoid
  has_paper_trail skip: %i[updated_at]

  belongs_to :user
  validates :uid, presence: true
  validates :provider, presence: true
  validates :uid, uniqueness: { scope: :provider, case_sensitive: false }

  # Tries to find an existing identity matching this oauth response
  # If one doesn't exist, a new one is initialised
  def self.from_oauth(auth)
    find_or_initialize_by(provider: auth[:provider], uid: auth[:uid]) do |ident|
      ident.info = auth[:info]
    end
  end
end
