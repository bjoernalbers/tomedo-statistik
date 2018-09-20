class VisitDoctor < ApplicationRecord
  self.table_name = 'besuch_behandelnderarzt'

  belongs_to :visit, foreign_key: 'besuch_ident'
  belongs_to :doctor, foreign_key: 'behandelnderarzt_ident'
end
