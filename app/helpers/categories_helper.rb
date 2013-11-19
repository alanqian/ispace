module CategoriesHelper
  # to list of name[3], code[3]
  def to_hier3_list(categories)
    name = Array.new(3, "")
    code = Array.new(3, "")
    prev_index = -1
    list = []
    clear = true
    categories.each do |cat|
      index = (cat.code.length - 1) / 2
      if index <= prev_index
        # output the row, then empty it
        list.push(OpenStruct.new({name: name, code: code}))
        name = Array.new(3, "")
        code = Array.new(3, "")
        clear = true
      end
      code[index] = cat.code
      name[index] = cat.name
      clear = false
      prev_index = index
      #(index+1).upto(2) do |i|
      #  code[i] = cat.code
      #  name[i] = cat.name
      #end
    end
    # output the last row
    list.push(OpenStruct.new({name: name, code: code})) unless clear
    list
  end
end
