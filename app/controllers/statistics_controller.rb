class StatisticsController < ApplicationController
  def index
    @start = params[:start].present? ? params[:start].to_date : Time.zone.now.beginning_of_month.to_date
    @stop = params[:stop].present? ? params[:stop].to_date : Time.zone.now.to_date
    @appointment_count_by_study = Appointment.count_by_study(@start, @stop)
    @appointment_average_waiting_periods = Appointment.average_waiting_periods(@start, @stop)
    @appointment_appeared_patients_percent = Appointment.appeared_patients_percent(@start, @stop)
    @todo_average_waiting_times = Todo.average_waiting_times(@start, @stop)
    @visit_average_duration = Visit.average_duration(@start, @stop)
    @patientdetails_insurance_type_percent = Patientdetails.insurance_type_percent(@start, @stop)
  end
end
