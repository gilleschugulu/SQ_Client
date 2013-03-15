#!/usr/bin/env ruby
JS_SCRIPT_PATH = 'vendor/scripts/build_version.js'

def js_code(version, commit, short_commit, branch, t, author)
<<-EOS
var BuildVersion = {
  version     : '#{version.strip}',
  commit      : '#{commit.strip}',
  shortCommit : '#{short_commit.strip}',
  branch      : '#{branch.strip}',
  time        : '#{t.strip}',
  author      : '#{author.strip}',

  getCommitLink: function() {
    return 'https://github.com/ChuguluGames/triviasports-client/tree/'+BuildVersion.commit;
  },

  toShortString: function() {
    return 'v' + BuildVersion.version;
  },

  toString: function() {
    var b=BuildVersion;
    return b.toShortString() + ' of ' + b.time + ' | ' + b.shortCommit + ' by ' + b.author + ' on ' + b.branch;
  }
};
EOS
end

jsfile = File.new(JS_SCRIPT_PATH, 'w')
jsfile.write js_code `git describe master`,
  `git log -1 --pretty=format:%H`,
  `git log -1 --pretty=format:%h`,
  `git rev-parse --abbrev-ref HEAD`,
  Time.now.strftime("%Y-%m-%d %H:%M"),
  `git log -1 --pretty=format:%an`
jsfile.flush
jsfile.close

puts "DONE"