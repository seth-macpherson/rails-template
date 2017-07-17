class ReportDecorator < ApplicationDecorator
  delegate_all

  def primary_description
    object.title
  end
end
