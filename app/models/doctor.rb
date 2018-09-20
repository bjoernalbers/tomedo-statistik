class Doctor < ApplicationRecord
  self.table_name = 'behandelnderarzt'

  belongs_to :user, foreign_key: 'nutzer_ident'
end
