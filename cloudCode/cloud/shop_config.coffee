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
    category: 'Jetons'
    name: '500 J'
    value: 500
    product_id: "0.89SportQuiz"
    net_price: 0.54
    price: 0.89
    store_tax : 0.3 # 30%
    vat : 0.15
  ,
    category: 'Jetons'
    name: '2500 J'
    value: 2500
    product_id: "3.59SportQuiz"
    net_price: 2.19
    price: 3.59
    store_tax : 0.3
    vat : 0.15
  ,
    category: 'Jetons'
    name: '7500 J'
    value: 7500
    product_id: "8.99SportQuiz"
    net_price: 5.47
    price: 8.99
    store_tax : 0.3
    vat : 0.15
  ,
    category: 'Jetons'
    name: '20000 J'
    value: 20000
    product_id: "17.99SportQuiz"
    net_price: 10.95
    price: 17.99
    store_tax : 0.3
    vat : 0.15
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
