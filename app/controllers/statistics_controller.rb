class StatisticsController < ApplicationController
  def index
    @start = params[:start].present? ? params[:start] : Time.zone.now.beginning_of_month.to_date
    @stop = params[:stop].present? ? params[:stop] : Time.zone.now.to_date
    @appointments = Appointment.chart_data(@start, @stop)
  end
end
