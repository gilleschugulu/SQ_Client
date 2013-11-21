config =
  life_packs: [
    value: 5
    price: 500
  ,
    value: 10
    price: 900
  ,
    value: 50
    price: 4000
  ,
    value: 100
    price: 7000
  ,
    value: 300
    price: 15000
  ]

  bonus_packs: [
    value: 5
    price: 150
  ,
    value: 25
    price: 700
  ,
    value: 50
    price: 1200
  ]

  credit_packs: [
    value: 500
    product_id: "1.79SportQuiz"
    price: 0.89
    tax : 0.3 # 30%
  ,
    value: 2500
    product_id: "2.69SportQuiz"
    price: 3.59
    tax : 0.3
  ,
    value: 7500
    product_id: "9.99SportQuiz"
    price: 8.99
    tax : 0.3
  ,
    value: 20000
    product_id: "19.99SportQuiz"
    price: 17.99
    tax : 0.3
  ]

  free_packs:
    web: [
      text: 'Aime-nous !'
      name: 'facebook_like'
      value: 150
    ]
    ios: [
      text: 'Aime-nous !'
      name: 'facebook_like'
      value: 150
    ,
      text: 'Note le jeu'
      name: 'app_store_rating'
      value: 150
    ]

exports.task = (request, response) ->
	response.success(config)
