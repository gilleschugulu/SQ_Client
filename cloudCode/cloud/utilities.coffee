strcmpNoLength = (str1, str2) ->
  return 0 if str1 is str2
  if str1.length > str2.length
    longer = str1
    shorter = str2
    multi = 1
  else
    longer = str2
    shorter = str1
    multi = -1
  for char, charIndex in longer
    continue if char == shorter[charIndex]
    return (if char > shorter[charIndex] then 1 else -1) * multi

exports.sortByScoreAndAlphabetic = (players) ->
    players.sort (p1, p2) ->
      deltaScore = p2.get('score') - p1.get('score')
      return deltaScore unless deltaScore is 0
      strcmpNoLength(p1.get('username').toLowerCase(), p2.get('username').toLowerCase())