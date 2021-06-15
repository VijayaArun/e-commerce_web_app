cache [I18n.locale, 'small_variant', root_object]

node(:id) { |v| v.id }
node(:is_backorderable) { |v| v.is_backorderable? }
node(:total_on_hand) { |v| v.total_on_hand }
node(:is_destroyed) { |v| v.destroyed? }

child(:images => :images) { extends "spree/api/images/show" }
