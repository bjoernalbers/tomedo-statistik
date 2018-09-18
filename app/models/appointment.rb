class Appointment < ApplicationRecord
  self.table_name = 'termin'

  belongs_to :calendar, foreign_key: 'terminart_ident'

  def self.chart_data(start = 3.weeks.ago)
    # RAW SQL:
    #select
    #  count(*) as anzahl_termine,
    #  terminart.bezeichnung as bezeichnung
    #from
    #  termin
    #  join terminart on terminart.ident = termin.terminart_ident
    #group by
    #  terminart.bezeichnung
    #order by
    #   anzahl_termine desc
    # limit
    #   10
    # ;
    joins(:calendar).
      where('termin.beginn >= ?', start).
      group('terminart.bezeichnung').
      select('count(*) as anzahl_termine, terminart.bezeichnung as bezeichnung').
      order('anzahl_termine desc').
      limit(10)
  end
end
