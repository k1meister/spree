class ConvertJsonToJsonb < ActiveRecord::Migration[8.0]
  def up
    # Get all tables with json columns
    tables_with_json = ActiveRecord::Base.connection.execute(<<-SQL).to_a
      SELECT table_name, column_name
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND data_type = 'json'
        AND table_name LIKE 'spree_%'
      ORDER BY table_name, column_name
    SQL

    tables_with_json.each do |row|
      table_name = row['table_name']
      column_name = row['column_name']
      
      # Convert json to jsonb
      execute <<-SQL
        ALTER TABLE #{table_name}
        ALTER COLUMN #{column_name} TYPE jsonb USING #{column_name}::jsonb
      SQL
    end
  end

  def down
    # Get all tables with jsonb columns
    tables_with_jsonb = ActiveRecord::Base.connection.execute(<<-SQL).to_a
      SELECT table_name, column_name
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND data_type = 'jsonb'
        AND table_name LIKE 'spree_%'
      ORDER BY table_name, column_name
    SQL

    tables_with_jsonb.each do |row|
      table_name = row['table_name']
      column_name = row['column_name']
      
      # Convert jsonb back to json
      execute <<-SQL
        ALTER TABLE #{table_name}
        ALTER COLUMN #{column_name} TYPE json USING #{column_name}::json
      SQL
    end
  end
end

