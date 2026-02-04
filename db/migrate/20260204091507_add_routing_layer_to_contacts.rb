class AddRoutingLayerToContacts < ActiveRecord::Migration[8.0]
  def change
    # TASK-066: Track current routing layer (1=Team, 2=Regional, 3=National)
    add_column :contacts, :routing_layer, :integer, default: nil, comment: "Smart Routing layer: 1=Team, 2=Regional, 3=National"
  end
end
