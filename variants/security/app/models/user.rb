# A user is a security account attached to a person. A person can only have
# one user, but for omniauth, a user may have multiple identities (facebook, github)
class User < ApplicationRecord
  rolify
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  has_paper_trail skip: %i(
    reset_password_token reset_password_sent_at
    sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip
    confirmation_token confirmed_at confirmation_sent_at unconfirmed_email
    failed_attempts unlock_token
    remember_created_at updated_at
  )

  belongs_to :person
  has_many :identities, dependent: :destroy
  has_many :security_events, class_name: 'Audit::SecurityEvent'

  validates :person, uniqueness: true, presence: true

  after_create :auto_elevate!, if: :auto_elevate?

  def active_for_authentication?
    super && !disabled?
  end

  def self.find_for_authentication(tainted_conditions)
    find_first_by_auth_conditions(tainted_conditions, disabled: false)
  end

  # If the user already has an identity for this oauth response, get it
  # otherwise create one and associate it with this user
  def find_or_create_identity!(auth)
    ident = Identity.from_oauth auth

    # Identity already exist. Make sure it's valid...
    if ident.persisted? && ident.user != self
      raise "Identity is associated with another user (#{ident.user})."
    end

    ident.user = self
    ident.save!
    ident
  end

  def any_role?(*allowed_roles)
    (roles.pluck(:name).map(&:to_sym) & allowed_roles.flatten).any?
  end

  def role_names
    roles.pluck(:name).map(&:titleize)
  end

  def to_s
    "#{email} (#{roles.pluck(:name).uniq.map(&:titleize).join(', ')})"
  end

  protected

  def confirmation_required?
    auto_elevate?
  end

  # Based on email, automatically elevate user level
  def auto_elevate!
    add_role :superuser
  end

  def auto_elevate?
    email.ends_with? "@webgents.dk"
  end
end
