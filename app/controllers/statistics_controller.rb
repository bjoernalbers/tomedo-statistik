class StatisticsController < ApplicationController
  def index
    @appointments = Appointment.chart_data
  end
end
