# A report is an admin-defined SQL query that returns data and
# renders a chart.
class Report < ApplicationRecord
  acts_as_paranoid
  has_paper_trail skip: %i[updated_at]

  validates :title, presence: true
  validates :chart_type, presence: true
  validate :settings, :valid_json

  scope :published, -> { where(published: true) }

  def settings=(value)
    return self[:settings] = nil if value.blank?
    begin
      self[:settings] = JSON.parse(value)
    rescue JSON::ParserError => ex
      Rails.logger.warn "Failed to parse JSON for report settings: #{ex.message}"
      self[:settings] = value
    end
  end

  def unpublished?
    !published?
  end

  protected

  def valid_json
    return true if self[:settings].blank?
    return true if self[:settings].is_a?(Hash)
    begin
      !!JSON.parse(self[:settings])
    rescue JSON::ParserError => ex
      errors.add(:settings, "JSON can't be parsed: #{ex.message}")
    end
  end
end
