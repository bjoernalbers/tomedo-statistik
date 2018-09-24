class TodoTemplate < ApplicationRecord
  self.table_name = 'todovorlage'

  has_many :todos, foreign_key: 'todovorlage_ident'

  def self.studies
    where(name: %w(
      Stanze
      CT
      MR
      Mammo
      Galaktographie
      Röntgen
      Durchleuchtung
      DSA
      Sono
      PRT
      Tomosynthese
      MR-Biopsie
      CT-Biopsie/Punktion
    ))
  end
end
