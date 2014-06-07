Sequel.migration do
  up do
    create_table(:groups) do
      primary_key :id
      String :name
    end

    create_table(:notices) do
      primary_key :id
      foreign_key :group_id, :groups
      String :title
      String :content
      Time :issued_time
    end
  end

  down do
    drop_table(:notices)
    drop_table(:groups)
  end
end
