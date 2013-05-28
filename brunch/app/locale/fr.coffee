module.exports =
  fr:
    controller:
      home:
        facebook_invite_message: 'Ce jeu est FAIT pour toi !'
        app_request:
          error: 'Désolé vous avez déjà invité tous vos amis'
          success: "Merci d'avoir invité vos amis"
        touch_me:
          touch: 'Touche pour afficher la Une'
          loading: "Le journal est en cours de livraison !"
          error: "Le facteur s'est perdu"
        journal:
          twoplus:
            rank_1 : '{0} est numero uno'
            rank_2 : '{0} y est presque'
            rank_3 : '{0} décroche le bronze'
            rank_n : '{0} n\'est qu\'a la position {1}'
      shop:
        unavailable_pack:
          title: 'erreur'
          message: 'pack indisponible'
        not_enough_credits:
          title: 'Erreur'
          message: 'pas assez de crédits'
        bonus_pack_bought:
          title: 'Achat confirmé'
          message: "Tout c'est bien passé, bon jeu !"
        life_pack_bought:
          title: 'Achat confirmé'
          message: "Tout c'est bien passé, bon jeu !"
      game_over:
        stats:
          nb_questions: 'Nombre de questions'
          good_answers: 'Bonnes réponses'
          wrong_answers: 'Mauvaises réponses'
          best_row: 'Plus longue série'
      profile:
        stats:
          best_score: 'Meilleur score'
          avg_score: 'Score moyen'
          percent_answer: 'Bonne réponse'
          average_time: 'Réponse moyenne'
          games_played_count: 'Nombres partie'
          best_row: 'Combo réponse'
          best_sport: 'Sport favori'

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
      stats:
        no_best_sport: 'Aucun'
    view:
      outgame:
        login:
          already_email: "Un email vient d'être envoyé à {0} avec le code a renseigner."
          already_facebook: "Email déjà enregistré avec un compte facebook, on lance la connection facebook"
      game:
        dupa:
          welcome: "Bienvenue aux 4 candidats qui vont jouer aujourd'hui à {0}. Tout de suite première question"
    ranks:
      rank_1:
        name: "Maître des maîtres"
        img_name: "maitre_maitres"
      rank_2:
        name: "Maître de diamant"
        img_name: "maitre_diamant"
      rank_3:
        name: "Maître de platine"
        img_name: "maitre_platine"
      rank_4:
        name: "Maître d'or"
        img_name: "maitre_or"
      rank_5:
        name: "Maître d'argent"
        img_name: "maitre_argent"
      rank_6:
        name: "Maître de bronze"
        img_name: "maitre_bronze"
      rank_7:
        name: "Maitre de cuivre"
        img_name: "maitre_cuivre"
      rank_8:
        name: "Maitre de fer"
        img_name: "maitre_fer"
