class Visit < ApplicationRecord
  self.table_name = 'besuch'

  belongs_to :patient, foreign_key: 'patient_ident'
  has_one :visit_doctor, foreign_key: 'besuch_ident'
  has_one :doctor, through: :visit_doctor
  has_one :user, through: :doctor
  has_many :visit_todochain, foreign_key: 'todokette_ident'
  has_many :todos, through: :visit_todochain

  include Medianable

  def self.average_duration(start, stop)
    # Raw SQL:
    # SELECT
    #   nutzer.kuerzel as kuerzel,
    #   ROUND(EXTRACT(epoch FROM avg(ende - ankunft))/3600) as durchschnittliche_besuchsdauer
    # FROM
    #   "besuch"
    # INNER JOIN
    #   "besuch_behandelnderarzt" ON "besuch_behandelnderarzt"."besuch_ident" = "besuch"."ident"
    # INNER JOIN
    #   "behandelnderarzt" ON "behandelnderarzt"."ident" = "besuch_behandelnderarzt"."behandelnderarzt_ident"
    # INNER JOIN
    #   "nutzer" ON "nutzer"."ident" = "behandelnderarzt"."nutzer_ident"
    # WHERE
    #   "besuch"."ende" BETWEEN '2018-09-01 00:00:00' AND '2018-09-20 23:59:59.999999'
    # GROUP BY
    #   nutzer.kuerzel
    # ORDER BY
    #   durchschnittliche_besuchsdauer desc
    # ;
    joins(:user).
      where('besuch.ende' => start.to_date.beginning_of_day..stop.to_date.end_of_day).
      group('nutzer.kuerzel').
      select('nutzer.kuerzel as kuerzel, ROUND(EXTRACT(epoch FROM avg(ende - ankunft))/3600) as durchschnittliche_besuchsdauer').
      order('durchschnittliche_besuchsdauer desc')
  end

  def self.median_duration(start, stop)
    result = []
    subquery = joins(:user).
      select('nutzer.kuerzel as kuerzel, ROUND(EXTRACT(EPOCH FROM (ende - ankunft))/3600) as besuchsdauer').
      where(ende: start.to_date.beginning_of_day..stop.to_date.end_of_day).
      as('besuch')
    from(subquery).distinct.pluck(:kuerzel).each do |doctor|
      records = from(subquery).where(kuerzel: doctor)
      result << {
        kuerzel: doctor,
        median_besuchsdauer: records.median(:besuchsdauer)
      }
    end
    result.sort_by{ |r| r[:median_besuchsdauer] }.reverse
  end
end
