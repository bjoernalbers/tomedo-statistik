class User < ApplicationRecord
  self.table_name = 'nutzer'

  has_many :doctors, foreign_key: 'nutzer_ident'
end
