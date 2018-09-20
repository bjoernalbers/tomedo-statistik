class Patient < ApplicationRecord
  self.table_name = 'patient'

  belongs_to :patientdetails, foreign_key: 'patientendetails_ident'
  has_many :visits, foreign_key: 'patient_ident'
end
