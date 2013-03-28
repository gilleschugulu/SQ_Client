`Parse.Cloud.define("getGlobalScores", function(request, response) {
  var query;
  query = new Parse.Query("User");
  query.equalTo("rank", request.params.rank);
  query.descending("score")
  query.find({
    success: function(results) {`
      results = []
      #Find PLayer
      i = 0
      for [0..results.length]
        player = i  if results[i].id is 'request.params.id'
        i++
      #top postion
      if player < 6
        leaderboard = addToboard leaderboard, results, 0, 10
       #bottom position
      else if player > results.length -7
        leaderboard = addToboard leaderboard, results, 0, 3
        leaderboard = addToboard leaderboard, results, results.length-7, results.length
      #middle position
      else
      leaderboard = addToboard leaderboard, results, 0, 3
      leaderboard = addToboard leaderboard, results, player-3, player+4
    `response.success(leaderboard);
    },
    error: function() {
      response.error("failed");}
  });
});

function addToboard(tmp, results, min, max)
{
  for(var i=min; i<max; i++)
  {
    results[i].attributes.order = i+1;
    tmp.push(results[i]);
  }
  return tmp
}
