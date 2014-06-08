Sequel.migration do
  up do
    create_table(:groups) do
      Integer :id, primary_key: true
      String :name
    end

    create_table(:notices) do
      Integer :id, primary_key: true
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
