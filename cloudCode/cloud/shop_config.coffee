config =
  life_packs: [
    value: 5
    price: 500
  ,
    value: 10
    price: 1000
  ,
    value: 50
    price: 5000
  ,
    value: 100
    price: 10000
  ,
    value: 300
    price: 20000
  ]

  bonus_packs: [
    value: 5
    price: 150
  ,
    value: 25
    price: 750
  ,
    value: 50
    price: 1500
  ]

  credit_packs: [
    value: 100
    product_id: "1.79SportQuiz"
    price: 0.89
    tax : 0.3 # 30%
  ,
    value: 250
    product_id: "2.69SportQuiz"
    price: 3.59
    tax : 0.3
  ,
    value: 700
    product_id: "9.99SportQuiz"
    price: 8.99
    tax : 0.3
  ,
    value: 2000
    product_id: "19.99SportQuiz"
    price: 17.99
    tax : 0.3
  ]

  free_packs:
    web: [
      name: 'facebook_like'
      value: 150
    ]
    ios: [
      name: 'facebook_like'
      value: 150
    ,
      name: 'app_store_rating'
      value: 150
    ]

exports.task = (request, response) ->
	response.success(config)
