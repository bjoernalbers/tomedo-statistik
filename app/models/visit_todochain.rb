class VisitTodochain < ApplicationRecord
  self.table_name = 'besuch_todokette'

  belongs_to :todo, foreign_key: 'todokette_ident'
  belongs_to :visit, foreign_key: 'besuch_ident'
end
