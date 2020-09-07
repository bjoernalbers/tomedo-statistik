class Appointment < ApplicationRecord
  self.table_name = 'termin'

  belongs_to :calendar, foreign_key: 'terminart_ident'

  include Medianable

  def self.count_by_study(start, stop)
    # RAW SQL:
    # SELECT
    #   COUNT(*) as anzahl_termine,
    #   terminart.bezeichnung as bezeichnung
    # FROM
    #   termin
    #   INNER JOIN terminart on terminart.ident = termin.terminart_ident
    # GROUP BY
    #   terminart.bezeichnung
    # ORDER BY
    #   anzahl_termine DESC
    # LIMIT
    #   10
    # ;
    joins(:calendar).
      where('termin.beginn' => start.to_date.beginning_of_day..stop.to_date.end_of_day).
      where('termin.removed is false and termin.info is not null').
      group('terminart.bezeichnung').
      select('count(*) as anzahl_termine, terminart.bezeichnung as bezeichnung').
      order('anzahl_termine desc')
  end

  def self.average_waiting_periods(start, stop)
    # Raw SQL:
    # SELECT
    #   ROUND(EXTRACT(EPOCH FROM AVG(termin.beginn - termin.angelegt))/(60*60*24)) as durchschnittliche_wartezeit,
    #   terminart.bezeichnung as bezeichnung
    # FROM
    #   "termin"
    # INNER JOIN
    #   "terminart" ON "terminart"."ident" = "termin"."terminart_ident"
    # WHERE
    #   "termin"."angelegt" BETWEEN '2018-09-01 00:00:00' AND '2018-09-24 23:59:59.999999'
    # GROUP BY
    #   terminart.bezeichnung
    # ORDER BY
    #   durchschnittliche_wartezeit DESC
    # LIMIT 10
    # ;
    joins(:calendar).
      where('termin.angelegt' => start.to_date.beginning_of_day..stop.to_date.end_of_day).
      where('termin.removed is false and termin.info is not null').
      group('terminart.bezeichnung').
      select('ROUND(EXTRACT(EPOCH FROM AVG(termin.beginn - termin.angelegt))/(60*60*24)) as durchschnittliche_wartezeit, terminart.bezeichnung as bezeichnung').
      order('durchschnittliche_wartezeit desc')
  end

  def self.median_waiting_periods(start, stop)
    result = []
    subquery = joins(:calendar).
      select('terminart.bezeichnung as bezeichnung, ROUND(EXTRACT(EPOCH FROM(termin.beginn - termin.angelegt))/(60*60*24)) as wartezeit').
      where('termin.removed is false and termin.info is not null').
      where(angelegt: start.to_date.beginning_of_day..stop.to_date.end_of_day).
      as('termin')
    from(subquery).distinct.pluck(:bezeichnung).each do |bezeichnung|
      records = from(subquery).where(bezeichnung: bezeichnung)
      result << {
        bezeichnung: bezeichnung,
        median_wartezeit: records.median(:wartezeit)
      }
    end
    result.sort_by{ |r| r[:median_wartezeit] }.reverse
  end

  def self.appeared_patients_percent(start, stop)
    # Raw SQL:
    # SELECT
    #   warda,
    #   count(*) as anzahl
    # FROM
    #   "termin"
    # WHERE
    #   "termin"."beginn" BETWEEN '2018-09-01 00:00:00' AND '2018-09-25 23:59:59.999999'
    # GROUP BY
    #   "termin"."warda"
    # ;
    total = where(beginn: start.to_date.beginning_of_day..stop.to_date.end_of_day).
      where('termin.removed is false and termin.info is not null').
      count
    select('warda, count(*) as anzahl').
      where(beginn: start.to_date.beginning_of_day..stop.to_date.end_of_day).
      where('termin.removed is false and termin.info is not null').
      group(:warda).inject([]) do |memo,appeared_or_not|
        hash = {}
        hash[:label] = appeared_or_not.warda ? "erschienen" : "nicht erschienen"
        hash[:value] = ((appeared_or_not.anzahl.to_f / total.to_f) * 100.0).round
        memo << hash
        memo
      end
  end
end
