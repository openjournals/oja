class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.string :title
      t.string :github_address
      t.string :version, :default => "1.0"
      t.string :state
      t.string :category
      t.string :arxiv_id
      t.timestamps
    end
  end
end
