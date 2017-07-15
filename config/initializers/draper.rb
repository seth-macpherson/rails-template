# Allow Draper and Kaminari to play nicely together
Draper::CollectionDecorator.delegate :current_page, :total_pages, :limit_value, :total_count
