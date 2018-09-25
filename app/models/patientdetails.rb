class Patientdetails < ApplicationRecord
  self.table_name = 'patientendetails'

  has_one :patient, foreign_key: 'patientendetails_ident'
  has_many :visits, through: :patient

  def self.insurance_type_share(start, stop)
    # Raw SQL
    # SELECT
    #   count(*) as value,
    #   privatpatient as label FROM "patientendetails"
    # INNER JOIN
    #   "patient" ON "patient"."patientendetails_ident" = "patientendetails"."ident"
    # INNER JOIN
    #   "besuch" ON "besuch"."patient_ident" = "patient"."ident"
    # WHERE
    #   "besuch"."ende" BETWEEN '2018-09-01 00:00:00' AND '2018-09-20 23:59:59.999999'
    # GROUP BY
    #   "patientendetails"."privatpatient"
    # ;
    joins(:visits).
      where('besuch.ende' => start.to_date.beginning_of_day..stop.to_date.end_of_day).
      select('count(*) as value,privatpatient as label').
      group(:privatpatient)
  end
end
