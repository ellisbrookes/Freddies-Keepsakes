class RenameStoreToFreddiesKeepsakes < ActiveRecord::Migration[8.1]
  OLD_NAME = "Freddies Personalised Boutique"
  NEW_NAME = "Freddies Keepsakes"

  def up
    execute "UPDATE spree_stores SET name = #{quote(NEW_NAME)} WHERE name = #{quote(OLD_NAME)}"
  end

  def down
    execute "UPDATE spree_stores SET name = #{quote(OLD_NAME)} WHERE name = #{quote(NEW_NAME)}"
  end

  private

  def quote(value)
    connection.quote(value)
  end
end
