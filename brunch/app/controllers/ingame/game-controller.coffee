Controller           = require 'controllers/base/controller'
mediator             = require 'mediator'
Player               = require 'models/ingame/player-model'
Factory              = require 'helpers/factory-helper'
ConfigHelper         = require 'helpers/config-helper'
AnalyticsHelper      = require 'helpers/analytics-helper'
FacebookHelper       = require 'helpers/facebook-helper'
PopUpHelper          = require 'helpers/pop-up-helper'
i18n                 = require 'lib/i18n'
QuestionsList        = require 'config/questions/questions'

module.exports = class GameController extends Controller
  historyURL: 'game'
  title: 'Jeu'

  currentController: null
  currentStageIndex: -1
  stageName        : null   # stage name that will be sent to the server
  i18nStageName    : null
  loaded           : no
  game             : {}
  players          : []     # Move this to game model ?
  stages: [{
    name: 'dupa'
    type: 'dupa'
    i18n_key: 'dupa'
  }]

  # Workflow
  #  =>
  #  When both done, load XStageController, where X is the current stage
  #  | Listen on event stage:finish, to increment currentStageIndex, and launch new loop
  # ------------------------------------------------------------------------------------
  index: =>
    PushNotifications?.block() # dont show push stuff while playing
    @subscribeEvent 'stage:finish', @finishGame
    @subscribeEvent 'game:finish', @finishGame
    @loadGame =>
      # return @finishGame()
      if @loaded
        @loadNextStage()

  payGame: ->
    user = Parse.User.current()

    return false if user.get('health') <= 0
    # This will save the new health locally and at distance
    user.set('health', user.get('health') - 1).save()

  loadGame: (callback) ->
    # TODO : No more 'coins' screen !
    return unless @payGame()

    # TODO : Check 'dat : Read json offline
    # response = {"stages":{"dupa":{"questions":[{"type":"PhotoMcq","difficulty":1,"text":"Est-ce vrai ? ","id":3677,"theme":"Culture generale","propositions":[{"is_valid":true,"image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/026/original/cat1.png?2013","id":10723,"text":"SiSi"},{"is_valid":false,"image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/027/original/cat2.png?2013","id":10724,"text":"Bof"},{"is_valid":false,"image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/028/original/cat4.png?2013","id":10725,"text":"Nop"},{"is_valid":false,"image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/029/original/cat3.png?2013","id":10726,"text":"Non plus"}]},{"type":"PhotoMcq","difficulty":1,"text":"Est-ce vrai ? ","id":3677,"theme":"Culture generale","propositions":[{"is_valid":true,"image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/026/original/cat1.png?2013","id":10723,"text":"SiSi"},{"is_valid":false,"image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/027/original/cat2.png?2013","id":10724,"text":"Bof"},{"is_valid":false,"image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/028/original/cat4.png?2013","id":10725,"text":"Nop"},{"is_valid":false,"image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/029/original/cat3.png?2013","id":10726,"text":"Non plus"}]}]},"stage_1":{"questions":[{"type":"MaskedOne","difficulty":1,"text":"Quel chef de guerre domina la majeure partie de l'Asie vers 1400 ?","id":73,"theme":"Histoire","propositions":[{"is_valid":true,"id":255,"text":"Tamerlan"},{"is_valid":false,"id":256,"text":"Genghis Khan"}]},{"type":"MaskedOne","difficulty":1,"text":"Lorsqu'on tente de s'accorder avec quelqu'un en faisant des concessions r\u00e9ciproques, on cherche...","id":74,"theme":"Langue","propositions":[{"is_valid":true,"id":257,"text":"Un compromis"},{"is_valid":false,"id":258,"text":"La bagarre"}]},{"type":"MaskedOne","difficulty":1,"text":"Au football, que signifient les initiales PSG ?","id":165,"theme":"Sport","propositions":[{"is_valid":true,"id":439,"text":"Paris Saint-Germain"},{"is_valid":false,"id":440,"text":"Pas Souvent Gagnant"}]},{"type":"MaskedOne","difficulty":1,"text":"Quels sont les pr\u00e9noms des comiques Laurel et Hardy ?","id":176,"theme":"People","propositions":[{"is_valid":true,"id":461,"text":"Stan et Oliver"},{"is_valid":false,"id":462,"text":"Eric et Ramzy"}]},{"type":"MaskedOne","difficulty":1,"text":"Sous quel pseudonyme Isabelle de Truchis de Varennes est-elle plus connue ?","id":183,"theme":"Musique","propositions":[{"is_valid":true,"id":475,"text":"Zazie"},{"is_valid":false,"id":476,"text":"Zabou"}]},{"type":"MaskedOne","difficulty":1,"text":"Dans la pens\u00e9e tao\u00c3\u00afste chinoise, quelle force cosmologique se manifeste surtout par le mouvement ?","id":168,"theme":"Culture generale","propositions":[{"is_valid":true,"id":445,"text":"Yang"},{"is_valid":false,"id":446,"text":"Yin"}]},{"type":"MaskedOne","difficulty":1,"text":"Quel mot d\u00e9signe une brochette japonaise ?","id":256,"theme":"Alimentation","propositions":[{"is_valid":true,"id":621,"text":"Yakitori"},{"is_valid":false,"id":622,"text":"Mikado"}]},{"type":"MaskedOne","difficulty":1,"text":"Dans le sud-est asiatique, on cultive le riz \u00c3\u00a0 flanc de montagne gr\u00c3\u00a2ce aux cultures dites...","id":85,"theme":"Geographie","propositions":[{"is_valid":true,"id":279,"text":"En terrasse"},{"is_valid":false,"id":280,"text":"En balcon"}]},{"type":"MaskedOne","difficulty":1,"text":"Quel est le premier James Bond \u00c3\u00a0 avoir \u00e9t\u00e9 adapt\u00e9 au cin\u00e9ma ?","id":375,"theme":"Cinema","propositions":[{"is_valid":true,"id":859,"text":"James Bond contre Dr No"},{"is_valid":false,"id":860,"text":"Goldfinger"}]},{"type":"MaskedOne","difficulty":1,"text":"Qu'indique la plus grande des aiguilles d'une montre ?","id":166,"theme":"Vie quotidienne","propositions":[{"is_valid":true,"id":441,"text":"Les minutes"},{"is_valid":false,"id":442,"text":"Les heures"}]}]},"stage_2":{"questions":[{"type":"Intruder","difficulty":1,"text":"Quelle demoiselle s'est mari\u00e9e \u00c3\u00a0 un pr\u00e9sident de la cinqui\u00e8me r\u00e9publique fran\u00e7aise ?","id":1109,"theme":"Histoire","propositions":[{"is_valid":true,"id":2327,"text":"Mlle Gouze"},{"is_valid":true,"id":2328,"text":"Mlle Vendroux"},{"is_valid":true,"id":2329,"text":"Mlle Cahour"},{"is_valid":true,"id":2330,"text":"Mlle Ciganer-Albeniz"},{"is_valid":true,"id":2331,"text":"Mlle Sauvage de Brantes"},{"is_valid":true,"id":2332,"text":"Mlle Chodron de Courcel"},{"is_valid":false,"id":2333,"text":"Mlle Perlant"}]},{"type":"Intruder","difficulty":1,"text":"Quelle forme du verbe \"aimer\" au subjonctif est correctement conjugu\u00e9e ?","id":1136,"theme":"Langue","propositions":[{"is_valid":true,"id":2516,"text":"Qu'il ait aim\u00e9"},{"is_valid":true,"id":2517,"text":"Que nous aimassions"},{"is_valid":true,"id":2518,"text":"Que j'aime"},{"is_valid":true,"id":2519,"text":"Qu'il aim\u00e2t"},{"is_valid":true,"id":2520,"text":"Que vous ayez aim\u00e9"},{"is_valid":true,"id":2521,"text":"Qu'elles eussent aim\u00e9"},{"is_valid":false,"id":2522,"text":"Que vous aim\u00e2tes"}]},{"type":"Intruder","difficulty":1,"text":"Quel animal fut une mascotte des Jeux Olympiques ?","id":1163,"theme":"Sport","propositions":[{"is_valid":true,"id":2705,"text":"Amik le castor"},{"is_valid":true,"id":2706,"text":"Powder le lapin"},{"is_valid":true,"id":2707,"text":"Syd l'ornithorynque"},{"is_valid":true,"id":2708,"text":"Misha l'ours"},{"is_valid":true,"id":2709,"text":"Sam l'aigle"},{"is_valid":true,"id":2710,"text":"Roni le raton laveur"},{"is_valid":false,"id":2711,"text":"Striker le chien"}]},{"type":"Intruder","difficulty":1,"text":"Quel Jean-Luc est c\u00e9l\u00e8bre ?","id":1134,"theme":"People","propositions":[{"is_valid":true,"id":2502,"text":"Le producteur Azoulay"},{"is_valid":true,"id":2503,"text":"Le chanteur Lahaye"},{"is_valid":true,"id":2504,"text":"Le journaliste Hees"},{"is_valid":true,"id":2505,"text":"Le violoniste Ponty"},{"is_valid":true,"id":2506,"text":"Le cin\u00e9aste Godard"},{"is_valid":true,"id":2507,"text":"Le footballeur Ettori"},{"is_valid":false,"id":2508,"text":"Le com\u00e9dien Dreyfus"}]},{"type":"Intruder","difficulty":1,"text":"Quelle chanson est interpr\u00e9t\u00e9e par Line Renaud ?","id":1112,"theme":"Musique","propositions":[{"is_valid":true,"id":2348,"text":"Ma cabane au Canada"},{"is_valid":true,"id":2349,"text":"Copacabana"},{"is_valid":true,"id":2350,"text":"Etoiles des neiges"},{"is_valid":true,"id":2351,"text":"Loulou"},{"is_valid":true,"id":2352,"text":"Mlle from Armenti\u00e8res"},{"is_valid":true,"id":2353,"text":"Itsi Bitsi petit bikini"},{"is_valid":false,"id":2354,"text":"Frida Oum Papa"}]},{"type":"Intruder","difficulty":1,"text":"C'est un Charles qui....","id":1110,"theme":"Culture generale","propositions":[{"is_valid":true,"id":2334,"text":"A \u00e9crit \"L'albatros\""},{"is_valid":true,"id":2335,"text":"A chant\u00e9 \"La boh\u00e8me\""},{"is_valid":true,"id":2336,"text":"A \u00e9crit \"Oliver Twist\""},{"is_valid":true,"id":2337,"text":"A jou\u00e9 dans \"V\u00e9ra Cruz\""},{"is_valid":true,"id":2338,"text":"A \u00e9t\u00e9 Roi des Espagnes"},{"is_valid":true,"id":2339,"text":"A chant\u00e9 \"Douce France\""},{"is_valid":false,"id":2340,"text":"A r\u00e9alis\u00e9 \"Le Placard\""}]},{"type":"Intruder","difficulty":1,"text":"Pour 100 grammes, quel aliment apporte moins de 250 calories ?","id":1135,"theme":"Alimentation","propositions":[{"is_valid":true,"id":2509,"text":"Un avocat"},{"is_valid":true,"id":2510,"text":"Une banane"},{"is_valid":true,"id":2511,"text":"Un foie de veau"},{"is_valid":true,"id":2512,"text":"Des moules"},{"is_valid":true,"id":2513,"text":"Des pommes de terre"},{"is_valid":true,"id":2514,"text":"Des sardines grill\u00e9es"},{"is_valid":false,"id":2515,"text":"Une noix de coco"}]},{"type":"Intruder","difficulty":1,"text":"Quelle c\u00e9l\u00e8bre place pourrait contenir la pelouse du Stade de France ?","id":1111,"theme":"Geographie","propositions":[{"is_valid":true,"id":2341,"text":"Vend\u00f4me \u00e0 Paris"},{"is_valid":true,"id":2342,"text":"Rouge \u00e0 Moscou"},{"is_valid":true,"id":2343,"text":"Tian-an-Men \u00e0 P\u00e9kin"},{"is_valid":true,"id":2344,"text":"Saint-Pierre \u00e0 Rome"},{"is_valid":true,"id":2345,"text":"Bellecour \u00e0 Lyon"},{"is_valid":true,"id":2346,"text":"Quinconces \u00e0 Bordeaux"},{"is_valid":false,"id":2347,"text":"Grand Place \u00e0 Bruxelles"}]},{"type":"Intruder","difficulty":1,"text":"Quel film met en sc\u00e8ne les Jeux Olympiques ?","id":1114,"theme":"Cinema","propositions":[{"is_valid":true,"id":2362,"text":"Les Chariots de feu"},{"is_valid":true,"id":2363,"text":"Munich"},{"is_valid":true,"id":2364,"text":"Les Rois du patin"},{"is_valid":true,"id":2365,"text":"Rasta Rockett"},{"is_valid":true,"id":2366,"text":"L'As des as"},{"is_valid":true,"id":2367,"text":"Les Fous du stade"},{"is_valid":false,"id":2368,"text":"La Victoire en chantant"}]},{"type":"Intruder","difficulty":1,"text":"Que peut-on voir sur le verso de tous les billets en euros ?","id":1124,"theme":"Vie quotidienne","propositions":[{"is_valid":true,"id":2432,"text":"Un pont"},{"is_valid":true,"id":2433,"text":"Moins de 12 \u00e9toiles"},{"is_valid":true,"id":2434,"text":"Euro \u00e9crit en grec"},{"is_valid":true,"id":2435,"text":"Un num\u00e9ro de s\u00e9rie"},{"is_valid":true,"id":2436,"text":"Carte de l'Europe"},{"is_valid":true,"id":2437,"text":"Euro \u00e9crit en fran\u00e7ais"},{"is_valid":false,"id":2438,"text":"Bande holographique"}]}]},"stage_3":{"questions":[{"type":"SingleAnswer","difficulty":1,"text":"Quel mot d\u00e9signe \u00c3\u00a0 la fois une maladie infantile et une moiti\u00e9 d'abricot d\u00e9noyaut\u00e9 ?","id":1870,"theme":"Histoire","propositions":[{"is_valid":true,"id":7372,"text":"Oreillon"}]},{"type":"SingleAnswer","difficulty":1,"text":"Quelle est la traduction fran\u00e7aise du verbe anglais \"to jump\" ?","id":1946,"theme":"Langue","propositions":[{"is_valid":true,"id":7448,"text":"Sauter"}]},{"type":"SingleAnswer","difficulty":1,"text":"Quel joueur Yannick Noah a-t-il battu en finale de Roland-Garros, en 1983 ?","id":1828,"theme":"Sport","propositions":[{"is_valid":true,"id":7330,"text":"Mats Wilander"}]},{"type":"SingleAnswer","difficulty":1,"text":"Quel \u00e9tait le surnom de Margaret Thatcher ?","id":1824,"theme":"People","propositions":[{"is_valid":true,"id":7326,"text":"Dame de fer"}]},{"type":"SingleAnswer","difficulty":1,"text":"De quel groupe Peter Gabriel et Phil Collins ont-ils \u00e9t\u00e9 membres ?","id":1830,"theme":"Musique","propositions":[{"is_valid":true,"id":7332,"text":"Genesis"}]},{"type":"SingleAnswer","difficulty":1,"text":"De quel mouvement artistique Andr\u00e9 Breton est-il un des p\u00e8res fondateurs ?","id":1825,"theme":"Culture generale","propositions":[{"is_valid":true,"id":7327,"text":"surr\u00e9alisme"}]},{"type":"SingleAnswer","difficulty":1,"text":"De quel pays le \"caldo verde\" est-il une sp\u00e9cialit\u00e9 ?","id":1834,"theme":"Alimentation","propositions":[{"is_valid":true,"id":7336,"text":"Portugal"}]},{"type":"SingleAnswer","difficulty":1,"text":"Dans quel d\u00e9partement fran\u00e7ais est enclav\u00e9e la principaut\u00e9 de Monaco ?","id":1832,"theme":"Geographie","propositions":[{"is_valid":true,"id":7334,"text":"Alpes-Maritimes"}]},{"type":"SingleAnswer","difficulty":1,"text":"Quel acteur incarne Jonathan Harker dans \"Dracula\" de Francis Ford Coppola ?","id":1826,"theme":"Cinema","propositions":[{"is_valid":true,"id":7328,"text":"Keanu Reeves"}]},{"type":"SingleAnswer","difficulty":1,"text":"Combien de jours de la semaine ne se terminent pas par la lettre \"i\" ?","id":1823,"theme":"Vie quotidienne","propositions":[{"is_valid":true,"id":7325,"text":"Un"}]}]},"stage_4":{"questions":[{"type":"MaskedFinal","difficulty":2,"text":"Comment a-t-on appel\u00e9 les ann\u00e9es qui ont suivi la Premi\u00e8re Guerre mondiale ?","id":2973,"theme":"Histoire","propositions":[{"is_valid":true,"id":8611,"text":"Les Ann\u00e9es folles"},{"is_valid":false,"id":8612,"text":"La Chouette Epoque"},{"is_valid":false,"id":8613,"text":"La Belle P\u00e9riode"}]},{"type":"MaskedFinal","difficulty":3,"text":"A quelle figure de style a-t-on recours lorsqu'on adoucit une expression jug\u00e9e trop choquante ?","id":3006,"theme":"Langue","propositions":[{"is_valid":true,"id":8710,"text":"Un euph\u00e9misme"},{"is_valid":false,"id":8711,"text":"Une anacoluthe"},{"is_valid":false,"id":8712,"text":"Un oxymore"}]},{"type":"MaskedFinal","difficulty":1,"text":"A quel sport le sigle NBA fait-il r\u00e9f\u00e9rence ?","id":2905,"theme":"Sport","propositions":[{"is_valid":true,"id":8407,"text":"Le basket-ball"},{"is_valid":false,"id":8408,"text":"Le volley-ball"},{"is_valid":false,"id":8409,"text":"Le hand-ball"}]},{"type":"MaskedFinal","difficulty":1,"text":"Avec qui Christian Clavier a-t-il eu une fille ?","id":2924,"theme":"People","propositions":[{"is_valid":true,"id":8464,"text":"Marie-Anne Chazel"},{"is_valid":false,"id":8465,"text":"An\u00e9mone"},{"is_valid":false,"id":8466,"text":"Marianne James"}]},{"type":"MaskedFinal","difficulty":1,"text":"Qui annonce en 1963 que \"l'Ecole est finie\" ?","id":2913,"theme":"Musique","propositions":[{"is_valid":true,"id":8431,"text":"Sheila"},{"is_valid":false,"id":8432,"text":"France Gall"},{"is_valid":false,"id":8433,"text":"Sylvie Vartan"}]}]},"stage_5":{"questions":[{"type":"MysteryStar","difficulty":1,"text":"Ah ? ","id":3678,"image":"http://s3-eu-west-1.amazonaws.com/midi-dev/images/attachments/000/000/031/original/Capture_d%E2%80%99%C3%A9cran_2013-01-07_%C3%A0_17.49.07.png?2013","theme":"Alimentation","progress_step":30,"positions":[{"x":0,"y":2,"step":26},{"x":4,"y":2,"step":27},{"x":4,"y":3,"step":28},{"x":5,"y":4,"step":29},{"x":1,"y":4,"step":30}],"rows":5,"columns":6,"propositions":[{"is_valid":true,"id":10727,"text":"Chugulu"}]}]}},"credits":754}
    response = 
      stages: 
        dupa:
          questions:
            QuestionsList

    console.log 'GAME => ', response
    @game = response
    @initPlayers()
    @loaded = yes
    callback()
      # , (response) =>
      #   @subscribeEvent 'popup:api-error:disposed', => @redirectTo 'home'
      #   PopUpHelper.initialize
      #     title  : i18n.t('helper.apiCall.error.title')
      #     message: apiResponse.error.messages
      #     key    : 'api-error'

  finishGame: =>
    console.log 'Game finish'
    human = @players[0]
    console.log human, @players

    # Track endgames
    AnalyticsHelper.trackPageView "EndGame - #{@i18nStageName}"

    data =
      jackpot    : human.get('jackpot')
      uuid       : mediator.user.get('uuid')

    @redirectToRoute "game-lost", {jackpot: human.get('jackpot'), reward: 10, rank: human.get('rank')}

    # TODO : Check 'dat : Contact Parse
    # ApiCallHelper.send.gameFinish data
    #   , (response) =>
    #     console.log "SUCCESS", response
    #     score = parseInt(response.jackpot, 10)
    #     unless isNaN(score)
    #       FacebookHelper.postScore score
    #     totalScore = parseInt(response.total_jackpot, 10)
    #     unless isNaN(totalScore)
    #       GameCenter?.reportScore totalScore, ConfigHelper.config.gamecenter.leaderboard
    #     @redirectToRoute "game-#{if !human.isEliminated() then 'won' else 'lost'}", {jackpot: human.get('jackpot'), reward: 10, rank: human.get('rank')}
    #   , (response) =>
    #     console.log "ERROR", response
    #     @redirectToRoute "game-#{if !human.isEliminated() then 'won' else 'lost'}", {jackpot: human.get('jackpot'), reward: 10, rank: human.get('rank')}

  # Load next stage
  # --------------------
  loadNextStage: =>
    return if not @loaded
    @currentStageIndex++
    stage = @stages[@currentStageIndex]
    @i18nStageName = stage.i18n_key
    @stageName = stage.name if not /duel/.test stage.name # set current stage name, skip duels (duel = stage before duel)
    @currentController?.dispose()
    @currentController = Factory.stageController stage, @players, @game.stages[stage.name]
    @currentController.start()

    # Track start stages
    AnalyticsHelper.trackPageView @i18nStageName

  initPlayers: =>
    @players = [new Player(Parse.User.current().attributes)]

  dispose: ->
    @currentController?.dispose()
    super
