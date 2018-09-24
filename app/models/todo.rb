class Todo < ApplicationRecord
  self.table_name = 'todo'

  belongs_to :todo_template, foreign_key: 'todovorlage_ident'
  has_one :visit_todochain, foreign_key: 'todokette_ident'
  has_one :visit, through: :visit_todochain

  def self.average_waiting_times(start, stop)
    # SELECT
    #   ROUND(EXTRACT(EPOCH FROM AVG(todo.anfang - besuch.ankunft))/60) as durchschnittliche_wartezeit,
    #   todovorlage.name as bezeichnung
    # FROM
    #   "todo"
    # INNER JOIN
    #   "todovorlage" ON "todovorlage"."ident" = "todo"."todovorlage_ident"
    # INNER JOIN
    #   "besuch_todokette" ON "besuch_todokette"."todokette_ident" = "todo"."ident"
    # INNER JOIN
    #   "besuch" ON "besuch"."ident" = "besuch_todokette"."besuch_ident"
    # WHERE
    #   "todo"."anfang" IS NOT NULL AND
    #   "todo"."anfang" BETWEEN '2018-09-01 00:00:00' AND '2018-09-24 23:59:59.999999'AND
    #   "todovorlage"."name" IN('Stanze', 'CT', 'MR', 'Mammo', 'Galaktographie', 'Röntgen', 'Durchleuchtung', 'DSA', 'Sono', 'PRT', 'Tomosynthese', 'MR-Biopsie', 'CT-Biopsie/Punktion')
    # GROUP BY
    #   todovorlage.name
    # ORDER BY
    #   durchschnittliche_wartezeit DESC
    # ;
    joins(:todo_template).
      joins(:visit).
      select('ROUND(EXTRACT(EPOCH FROM AVG(todo.anfang - besuch.ankunft))/60) as durchschnittliche_wartezeit, todovorlage.name as bezeichnung').
      started.
      where('besuch.ankunft' => start.to_date.beginning_of_day..stop.to_date.end_of_day).
      merge(TodoTemplate.studies).
      group('todovorlage.name').
      order('durchschnittliche_wartezeit DESC')
  end

  def self.started
    where.not(anfang: nil)
  end
end
