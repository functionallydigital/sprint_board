class Priority
  PRIORITY_LEVELS = [{value: 1, label: 'Must'}, {value: 2, label: 'Should'}, {value: 3, label: 'Could'}, {value: 4, label: 'Would'}]

  def self.find_priority(id)
    id ? PRIORITY_LEVELS.select{|level| level[:value] == id}.first : ''
  end

  def self.find_label(id)
    id ? PRIORITY_LEVELS.select{|level| level[:value] == id}.first[:label] : nil
  end
end
