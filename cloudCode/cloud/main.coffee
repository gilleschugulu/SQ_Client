#Find PLayer
for [0..results.length]
  player = i  if results[i].id is request.params.id
  i++
#top postion
leaderboard = addToboard leaderboard, results, 0, 10 if player < 6
 #bottom position
 else if player > results.length -7
  leaderboard = addToboard leaderboard, results, 0, 3
  leaderboard = addToboard leaderboard, results, results.length-7, results.length
#middle position
else
leaderboard = addToboard leaderboard, results, 0, 3
leaderboard = addToboard leaderboard, results, player-3, player+4
