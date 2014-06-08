Sequel.migration do
  up do
    self[:groups].insert(id: 0, name: '全体')
    self[:groups].insert(id: 2574, name: '全大学院生')
    self[:groups].insert(id: 2576, name: '学部学生')
  end
end
