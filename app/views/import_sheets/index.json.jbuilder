json.array!(@import_sheets) do |import_sheet|
  json.extract! import_sheet, :store_id, :user_id, :step, :filename, :comment, :ext, :imported, :data
  json.url import_sheet_url(import_sheet, format: :json)
end