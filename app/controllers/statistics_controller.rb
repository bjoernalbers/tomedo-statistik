class StatisticsController < ApplicationController
  def index
    @start = params[:start].present? ? params[:start].to_date : Time.zone.now.beginning_of_month.to_date
    @stop = params[:stop].present? ? params[:stop].to_date : Time.zone.now.to_date
    @appointments = Appointment.chart_data(@start, @stop)
    @visits = Visit.chart_data(@start, @stop)
    @patientdetails = Patientdetails.chart_data(@start, @stop)
  end
end
