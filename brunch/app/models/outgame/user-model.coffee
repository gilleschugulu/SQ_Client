module.exports = class User extends Parse.User
  defaults:
    uuid:           null
    avatar:         null
    credits:        50
    rank:           6
    score:          0
    health:         25
    notifications:  true
    providers:
      facebook: null
      equipe:   null
    bonus:
      fifty_fifty:  5
      double:       5
      add_time:     5
      skip:         5
      mass:         5
    stats:
      best_score:           0
      best_row:             0
      games_played_count:   0
      sum_score:            0
      sum_time_question:    0
      good_answers_count:   0
      wrong_answers_count:  0
      sports:               {}