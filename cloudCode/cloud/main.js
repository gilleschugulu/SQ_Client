Parse.Cloud.define("getGlobalScores", function(request, response) {

  var player;
  var query = new Parse.Query("User");
  query.equalTo("rank", request.params.rank);
  query.descending("score")
  query.find({
    success: function(results) {
      //Find player
      for (var i = 0; i<results.length; i++) {
        if(results[i].id === request.params.id)
          player = i
      }
      //top postion
      if(player<6)
        leaderboard = addToboard(leaderboard, results, 0, 10);
      //bottom position
      else if(player>results.length-7)
      {var leaderboard = [];
        leaderboard = addToboard(leaderboard, results, 0, 3);
        leaderboard = addToboard(leaderboard, results, results.length-7, results.length);
      }
      //middle position
      else
      {
        leaderboard = addToboard(leaderboard, results, 0, 3);
        leaderboard = addToboard(leaderboard, results, player-3, player+4);
      }
      response.success(leaderboard);
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

Parse.Cloud.define("sortLeaderBoard", function(request, response) {
  var query = new Parse.Query("Test");
  query.find({
    success: function(results){
      for(var i=0; i<results.length; i++)
      {results[i].destroy();
        console.log('object '+i);}
      response.success('did it');
    },
    error: function(results){
      response.error('didn t do it');
    }
  })
});
