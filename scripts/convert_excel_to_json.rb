#!/usr/bin/env ruby

puts 'Will parse "./questions.xlsx" file. Please wait'

require 'rubygems'
require 'json'
begin
  require 'roo'
rescue
  raise 'You should install the gem "roo"'
end

def extract_answer col
  text = @row[col]
  # Cells are automatically converted to float if number. Need to reconvert it to number
  if text.kind_of?(Float)
    # Need to check if intentional float or not (if fractional part is 0 or not)
    if (text - text.to_i).zero?
      text = text.to_i.to_s
    else
      text = text.to_s
    end
  end
  text
end

excel_klass = nil ; begin excel_klass = Excelx rescue excel_klass = Roo::Excelx end

# Find and read excel file to get correspondance answer <-> name. Only read first sheet
data = excel_klass.new('questions.xlsx')
data.default_sheet = data.sheets.first

questions = []
for i in 2..data.last_row
  begin
    @row = data.row(i)

    good_answer_index = ['A', 'B', 'C', 'D'].index(extract_answer(5)) + 1
    propositions =  []
    for j in 1..4
      answer = extract_answer(j)
      propositions.push({
        text: answer,
        is_valid: j == good_answer_index
      })
    end

    question = {
      text: extract_answer(0),
      category: extract_answer(6),
      difficulty: @row[7].to_i,
      sub_category: extract_answer(8),
      une_id: extract_answer(9),
      propositions: propositions
    }

    questions << question
  rescue
    puts "Row #{@row.inspect} failed."
  end
end

json = JSON::generate(questions)

File.open('generated.json', 'w') do |file|
  file.write(json)
end

puts 'Ok !'