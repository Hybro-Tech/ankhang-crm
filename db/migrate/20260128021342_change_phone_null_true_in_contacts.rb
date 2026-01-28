class ChangePhoneNullTrueInContacts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :contacts, :phone, true
  end
end
