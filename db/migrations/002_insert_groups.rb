Sequel.migration do
  up do
    self[:groups].insert(id: 1, name: '全体')
    self[:groups].insert(id: 2, name: '学部学生')
    self[:groups].insert(id: 3, name: '全大学院生')
  end

  down do
    self[:groups].delete
  end
end
