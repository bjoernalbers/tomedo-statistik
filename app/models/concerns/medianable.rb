module Medianable
  extend ActiveSupport::Concern

  class_methods do
    def median(column)
      elements = self.where.not(column => nil).order(column).pluck(column)
      count = elements.count
      median_index = count / 2
      if count.even?
        (elements[median_index-1] + elements[median_index]) / 2.0
      else
        elements[median_index]
      end
    end
  end
end
