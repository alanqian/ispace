module ActiveRecordExtension
  extend ActiveSupport::Concern

  def to_hash(key, *value_fields)
    case value_fields.length
    when 0
      return {}.tap { |h| self.each {|r| h[r[key]] = r}}
    when 1
      f = value_fields.first
      return {}.tap { |h| self.each {|r| h[r[key]] = r[f]}}
    else
      hash = {}
      self.each do |r|
        hash[r[key]] = {}.tap { |h| value_fields.each { |f| h[f] = r[f] }}
      end
      return hash
    end
  end

  def to_hierarchy(*key_fields, last_key_field, value_field)
    hash = {}
    self.each do |r|
      h = hash
      key_fields.each do |f|
        h[r[f]] ||= {}
        h = h[r[f]]
      end
      h[r[last_key_field]] = r[value_field]
    end
    hash
  end

  # simplified version of to_hierarchy
  def to_hash2(key_field1, key_field2, value_field)
    hash = {}
    self.each do |r|
      h = hash
      hash[r[key_field1]] ||= {}
      hash[r[key_field1]][r[key_field2]] = r[value_field]
    end
    hash
  end
end

# include the extension
ActiveRecord::Relation.send(:include, ActiveRecordExtension)
