#!/usr/bin/env ruby
IMAGES_PATH = 'app/assets/images'
JS_SCRIPT_PATH = 'vendor/scripts/assets_list.js'

def js_code
  filesList = []
  keys = []
  for path in Dir.glob(IMAGES_PATH + '/**/')
    key = path.gsub('app/assets/images/', '')
    value = "#{Dir.glob(path + '*').select {|path| path =~ /.*(png|jpg|jpeg)$/}.map {|path| path.gsub('app/assets/', '') }}"
    filesList << "'#{key}': #{value}" if value != "[]"
    keys << key
  end
  filesList = "{ #{filesList.join(",\n")} }"

  <<-EOS
var AssetsList = {
  assets: #{filesList},
  keys: {
    profile: ['profile', 'common'],
    home: ['home/1ami', 'home/2amis/', 'home/common/', 'home/pasamis/', 'home/+2amis'],
    invitation: ['invitation', 'common'],
    options: ['options'],
    'more-games': ['more-games', 'common'],
    'hall-of-fame': ['hall-of-fame'],
    stage_1: ['star-stage', 'common', 'star', 'duel', 'avatar', 'desk'],
    stage_duel: ['star-stage', 'duel', 'common', 'avatar', 'desk'],
    stage_2: ['star-stage', 'common', 'star', 'duel', 'avatar', 'desk'],
    stage_3: ['common']
  }
};
  EOS
end

jsfile = File.new(JS_SCRIPT_PATH, 'w')
jsfile.write js_code
jsfile.flush
jsfile.close

puts "DONE"
