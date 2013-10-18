module.exports =
  fr:
    controller:
      home:
        facebook_invite_message: 'Ce jeu est FAIT pour toi !'
        app_request:
          error: 'Désolé vous avez déjà invité tous vos amis'
          success: "Merci d'avoir invité vos amis"
          success_bonus: "Merci d'avoir invité vos amis ! Vous avez gagné {0} vie(s)."
        touch_me:
          touch: 'Touche pour afficher la Une'
          loading: "Le journal est en cours de livraison !"
          error: "Le facteur s'est perdu"
        journal:
          twoplus:
            rank_1 : '{0} est numero un'
            rank_2 : '{0} y est presque'
            rank_3 : '{0} décroche le bronze'
            rank_n : '{0} n\'est qu\'a la position {1}'
      game:
        not_enough_health:
          title: 'Oups...'
          message: 'Vous n\'avez plus de vies pour jouer !'
        could_not_pay:
          title: 'Erreur'
          message: 'Pas pu dépenser la vie pour jouer'
      hof:
        life_giveaway:
          success      : 'Vous venez d\'offrir une vie à {0} pour ce tournoi !'
          error        : 'Une erreur est survénue, veuillez réessayer plus tard.'
          already_given: 'Vous ne pouvez plus offrir de vie à {0} durant ce tournoi.'
      shop:
        fetch_packs_error:
          title: 'Erreur'
          message: 'La boutique est indisponnible pour le moment. Veuillez réessayer plus tard.'
        unavailable_pack:
          title: 'Erreur'
          message: 'Ce pack est indisponible'
        not_enough_credits:
          title: 'Erreur'
          message: 'Vous n\'avez pas assez de jetons'
      game_over:
        stats:
          nb_questions: 'Nombre de questions'
          good_answers: 'Bonnes réponses'
          wrong_answers: 'Mauvaises réponses'
          best_row: 'Plus longue série'
          game_row: 'Nombre de parties cette semaine'
        end_message:
          msg2k      : 'Voilà une performance digne d\'un relégable ! Il va falloir faire mieux pour se maintenir !'
          msg5k      : 'Une partie solide. Encore un petit effort pour assurer la montée.'
          msg10k     : 'Bien joué ! Continue comme ça pour atteindre les premières places !'
          msg25k     : 'Excellent ! Une performance digne du niveau supérieur !'
          msg25kplus : 'Fantastique ! Avec ce genre de performance tu peux viser la première place !'
      profile:
        stats:
          best_score: 'Meilleur score'
          avg_score: 'Score moyen'
          percent_answer: 'Bonne réponse'
          average_time: 'Réponse moyenne'
          games_played_count: 'Nombres partie'
          best_row: 'Combo réponse'
          best_sport: 'Sport favori'
      login:
        sso_equipe:
          error_title: 'Erreur'
          invalid: 'Le pseudo ou le mot de passe est invalide'
          user_not_found: "Ce pseudo n'existe pas"
          already_used: 'Ce pseudo ou cet email est déjà utilisé'
          incorrect_mail: 'Votre pseudo ou email n\'est pas reconnu'
          incorrect_password : 'Votre mot de passe est incorrect'
          unknown : 'Une erreur inconnue est survenue, veuillez réessayer plus tard'
          field_error_email : 'Veuillez rentrer un email correct'
          field_error_username : 'Votre pseudo doit être composé d\'au moins 6 lettres et/ou de chiffres'
          invalid_register_params : 'Veuillez remplir tous les champs'
          invalid_login_params : 'Votre pseudo ou mot de passe est incorrect'
    helper:
      app_store_link: "http://itunes.apple.com/app/les-12-coups-de-midi/id584885677?mt=8"
      game_icon: "https://midi-preproduction.chugulu.com/assets/Icon-72@2x.png"
      facebook:
        create_account_sucess:
          name: "Je joue aux 12 Coups de Midi!"
          description: "L'application du jeu télévisé! Rejoignez moi et essayez de découvrir ce que cache l'Etoile Mystérieuse!"
        discovered_star:
          name: "J'ai découvert l'Etoile Mystérieuse!"
          description: "Je joue aux 12 Coups de Midi! Rejoignez moi et essayez de découvrir ce que cache l'Etoile Mystérieuse!"
        became_master:
          name: "Je suis devenu Maître de Midi!"
          description: "Je joue aux 12 Coups de Midi! Rejoignez moi et essayez de découvrir ce que cache l'Etoile Mystérieuse!"
        did_master_piece:
          name: "J'ai réalisé un Coup de Maître!"
          description: "Je joue aux 12 Coups de Midi! Rejoignez moi et essayez de découvrir ce que cache l'Etoile Mystérieuse!"
      push:
        how_about_no: "Non, merci"
        kthx: "OK"
      apiCall:
        error:
          title: 'Erreur de connexion'
          connection: 'Vous devez être connecté à Internet pour pouvoir jouer à Sport Quiz'
          server: 'Il est impossible de contacter le serveur. Veuillez réessayer plus tard.'
          api: 'Une erreur est survenue. {0}.'
      purchase:
        apple:
          cancel:
            title: 'Erreur'
            message: 'Achat annulé'
          error:
            title: 'Erreur'
            message: 'erreur itunes'
        adcolony:
          quota_exceeded:
            title: 'erreur'
            message: "Vous avez epuisé vos recompenses pour aujourd'hui! Veuillez réessayer demain ou utilisez les autres moyens."
          error:
            title: 'Erreur'
            message: "Une erreur est survenue. Veuillez réessayer plus tard."
        facebook:
          invitation:
            text: 'accepte'
            reward : "Youpi ! tu as des credits en plus...ou pas"
        pack_bought:
          title: 'Achat confirmé'
          message: "Tout c'est bien passé, bon jeu !"
        unknown_error:
          title: 'Erreur'
          message: 'Une erreur est survenue, veuillez réessayer plus tard.'
      stats:
        no_best_sport: 'Aucun'
    view:
      hall_of_fame:
        players_up_rank: 'Ils vont monter au niveau'
        players_stay_rank: 'Ils vont rester au niveau'
        players_down_rank: 'Ils vont descendre au niveau' 
      game:
        dupa:
          welcome: "Bienvenue aux 4 candidats qui vont jouer aujourd'hui à {0}. Tout de suite première question"