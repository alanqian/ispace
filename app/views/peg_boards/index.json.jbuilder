json.array!(@peg_boards) do |peg_board|
  json.extract! peg_board, :bay_id, :level, :name, :height, :depth, :vert_space, :horz_space, :vert_start, :horz_start, :notch_num, :color
  json.url peg_board_url(peg_board, format: :json)
end