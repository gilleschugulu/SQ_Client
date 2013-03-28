#!/usr/bin/env ruby
# Create a git repo with two remotes
# with respectively two branches to track prod and preprod changes on github pages

TEMP_DIR = "deployment"
BUILD_DATA = "brunch/build/web"
TARGETS = %w{preprod}
GIT_URLS = {
  "preprod" => "git@github.com:ChuguluGames/sports_quiz_client.git"
}
CNAME_URLS = {
  "preprod" => "play-sport-quiz-preprod.chugulu.com"
}
GIT_BRANCH = "gh-pages"

def config(target)
  if !TARGETS.include?(target)
   puts "not supported target"
   exit
  end
  @source = target
  @branch = "#{@source}-#{GIT_BRANCH}"
  @repo_url = GIT_URLS[@source]
  @cname_url = CNAME_URLS[@source]
end

if $0 == __FILE__
  # Shows help on how to use this script
  def usage
    puts "Usage:\n" #@todo: add details about arguments
    puts "Deploy to preprod (develop)"
    puts "    ./deploy.rb [Message]\n\n"
    exit
  end

  # Main program
  config('preprod')
  @message = ARGV[0] || "pushing new version"

  # build project
  # result = system "cd brunch; brunch build -c config/web"
  # exit
  # clone repo

  if !File.exists?(TEMP_DIR)
    system "mkdir #{TEMP_DIR}"
    system "git init #{TEMP_DIR}"
    system "cd #{TEMP_DIR}; echo 'deployment test' > test"
    system "cd #{TEMP_DIR}; git add ."
    system "cd #{TEMP_DIR}; git commit -m 'test'"
    TARGETS.each do |t|
      system "cd #{TEMP_DIR}; git checkout -b #{t}-#{GIT_BRANCH}"
      system "cd #{TEMP_DIR}; git remote add #{t} #{GIT_URLS[t]}"
    end
  end

  # fetch last changes and prepare build
  system "cd #{TEMP_DIR}; git checkout #{@branch}"
  system "cd #{TEMP_DIR}; git pull #{@source} #{GIT_BRANCH}"
  system "cd #{TEMP_DIR}; git rm -rf ."
  system "cp -r #{BUILD_DATA}/* #{TEMP_DIR}/."
  system "echo #{@cname_url} > #{TEMP_DIR}/CNAME"

  # push new release
  system "cd #{TEMP_DIR}; git add ."
  system "cd #{TEMP_DIR}; git commit -am '#{@message}'"
  system "cd #{TEMP_DIR}; git push #{@source} #{@branch}:#{GIT_BRANCH}"
  puts "\nSee results on #{@cname_url}"
end