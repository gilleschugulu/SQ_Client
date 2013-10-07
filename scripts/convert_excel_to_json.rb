#!/usr/bin/env ruby

xlsdir = ARGV[0]
if xlsdir.nil? or xlsdir.empty?
  puts "Usage : ./script <XLS folder path>"
  exit
end

puts "Will search in #{xlsdir} file. Please wait"

require 'rubygems'
require 'json'
require 'i18n'
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

excelx_klass = nil ; begin excelx_klass = Excelx rescue excelx_klass = Roo::Excelx end
excel_klass = nil ; begin excel_klass = Excel rescue excel_klass = Roo::Excel end

questions = []
unique_question_id = 1

Dir["#{xlsdir}/*.{xls,xlsx}"].each do |f|
  puts f
  # exit
  # Find and read excel file to get correspondance answer <-> name. Only read first sheet
  data =  f.match(/xlsx$/) ? excelx_klass.new(f) : excel_klass.new(f)
  data.default_sheet = data.sheets.first

  column_indexes = {}
  column_names   = data.row(1)
  [ 'Question', 'A', 'B', 'C', 'D', 'Answer', 'Category', 'Vaste categorie', 'Level', 'Photo' ].each do |name|
    column_indexes[name] = column_names.index(name)
    puts "nil index for #{name} !!!!!" if column_indexes[name].nil?
    # eval("column_indexes['#{name.gsub(' ','_').upcase} = column_names.index(name)") # column_indexes['QUESTION = column_names.index("Question")
  end
  # exit

  for i in 2..data.last_row

    # Row look like : 
    # enonce | answer A | answer B | answer C | answer D | Good answer | category | real_category | level | une

    begin
      @row = data.row(i)

      good_answer_index = column_names.index(extract_answer(column_indexes['Answer']))
      propositions =  []
      has_answer = false
      for j in [ column_indexes['A'], column_indexes['B'], column_indexes['C'], column_indexes['D'] ]
        answer = extract_answer(j)
        propositions.push({
          id: j,
          text: answer,
          is_valid: j == good_answer_index
        })
        has_answer |= j == good_answer_index
      end

      question = {
        id: unique_question_id,
        text: extract_answer(column_indexes['Question']),
        category: I18n.transliterate(extract_answer(column_indexes['Vaste categorie'])),
        difficulty: @row[column_indexes['Level']].to_i || 1,
        sub_category: I18n.transliterate(extract_answer(column_indexes['Category'])),
        une_id: extract_answer(column_indexes['Photo']) || 0,
        propositions: propositions
      }

      # puts "NO ASWER #{question.inspect}" unless has_answer
      unless question[:text].nil? or question[:text].empty? or !has_answer
        questions << question
        unique_question_id += 1
      end

    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      puts "Row failed : #{@row.inspect}"
    end
  end
end

json = "module.exports =\n  "
json += JSON::generate(questions)
File.open('generated.coffee', 'w') do |file|
  file.write(json)
end

puts "Ok ! #{unique_question_id} questions"