ranks_percentages = require('cloud/ranks_percentages.js').data
exports.task = (request, response) ->
  rank = request.params.rank
  if rank
    response.success(ranks_percentages[rank])
  else
    response.success(ranks_percentages)