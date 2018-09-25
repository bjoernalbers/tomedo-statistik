class Patientdetails < ApplicationRecord
  self.table_name = 'patientendetails'

  has_one :patient, foreign_key: 'patientendetails_ident'
  has_many :visits, through: :patient

  def self.insurance_type_percent(start, stop)
    # Raw SQL
    # SELECT
    #   count(*) as anzahl,
    #   privatpatient
    # FROM
    #   "patientendetails"
    # INNER JOIN
    #   "patient" ON "patient"."patientendetails_ident" = "patientendetails"."ident"
    # INNER JOIN
    #   "besuch" ON "besuch"."patient_ident" = "patient"."ident"
    # WHERE
    #   "besuch"."ende" BETWEEN '2018-09-01 00:00:00' AND '2018-09-20 23:59:59.999999'
    # GROUP BY
    #   "patientendetails"."privatpatient"
    # ;
    total = joins(:visits).
      where('besuch.ende' => start.to_date.beginning_of_day..stop.to_date.end_of_day).
      count
    joins(:visits).
      where('besuch.ende' => start.to_date.beginning_of_day..stop.to_date.end_of_day).
      select('count(*) as anzahl,privatpatient').
      group(:privatpatient).inject([]) do |memo,insurance_type|
        hash = {}
        hash[:label] = insurance_type.privatpatient ? "privat" : "gesetzlich"
        hash[:value] = ((insurance_type.anzahl.to_f / total.to_f) * 100.0).round
        memo << hash
        memo
      end
  end
end
