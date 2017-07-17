class ReportsController < BaseResourcesController
  before_action :set_options, only: %i(new create update edit)
  skip_before_action :set_resource, only: %i(preview)

  def show
    @render_method = "#{@report.chart_type}_chart"
    @options = {
      download: @report.title
    }
    @options.merge!(@report.settings) if @report.settings.is_a?(Hash)
    @result = QueryRunner.execute(@report.query)

    if @result.is_a? ActiveRecord::ActiveRecordError
      Rails.logger.error "Failed to generate report #{@report.id}: #{@result.message}"
    end

    super
  end

  # For async charts, exec the query and return the data
  def data
    authorize @report
    @result = QueryRunner.execute(@report.query)
    render json: @result.values
  end

  # Executes outside the context of a specific report
  # The query is POST'd and a rendered partial or json can be returned.
  # This allows the "Preview" button on the report editor to work
  def preview
    authorize :report
    @result = QueryRunner.execute(params[:query])

    # If the result is an error, respond accordingly
    if @result.is_a? ActiveRecord::ActiveRecordError
      respond_to do |format|
        format.json { render json: { success: false, message: @result.message }, status: :unprocessable_entity }
        format.html { render text: @result.message, status: :unprocessable_entity }
      end
      return
    end

    @data = {
      fields: @result.fields, values: @result.values
    }
    respond_to do |format|
      format.json { render json: { success: true, data: @data } }
      format.html { render :preview, layout: nil }
    end
  end

  protected

  def set_options
    @chart_type_options = [
      %w[Line line],
      %w[Bar bar],
      %w[Pie pie],
      %w[Column column]
    ]
  end
end
