class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  enum date_range: [:last_1_week, :last_1_month, :last_1_year]

  # Caution: for PSQL only
  def self.order_by_ids(ids)
    order_by = ["case"]
    ids.each_with_index.map do |id, index|
      order_by << "WHEN id='#{id}' THEN #{index}"
    end
    order_by << "end"
    order(Arel.sql(order_by.join(" ")))
  end
end
