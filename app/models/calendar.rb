class Calendar < ApplicationRecord
  self.table_name = 'terminart'

  has_many :appointments, foreign_key: 'terminart_ident'
end
