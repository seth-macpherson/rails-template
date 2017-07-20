# A human being
class Person < ApplicationRecord
  acts_as_paranoid
  has_paper_trail skip: %i[updated_at]

  # has_one :user

  validates :email, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :first_name, presence: true

  # before_destroy :ensure_no_user

  def age
    return nil if born_on.nil?
    now = Time.now.utc.to_date
    had_birthday = (now.month > born_on.month || (now.month == born_on.month && now.day >= born_on.day))
    now.year - born_on.year - (had_birthday ? 0 : 1)
  end

  def birthday_today?(date = Time.current)
    return false if born_on.nil?
    born_on.month == date.month && born_on.day == date.day
  end

  # Ensure that email addresses are lowercase and have no whitespace padding
  def email=(value)
    self[:email] = value.try(:downcase).try(:strip)
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def name=(value)
    if value.nil?
      self.first_name = nil
      self.last_name = nil
    else
      self.first_name, self.last_name = value.split(/\s+/, 2)
    end
  end

  def to_s
    name
  end

  protected

  def ensure_no_user
    return unless user.present?
    errors.add(:base, "Cannot delete a person that has a user account")
    throw(:abort)
  end
end
