module.exports =
  fr:
    controller:
      invite:
        facebook_invite_message: 'Vasy rejoins ce jeu il déchire'
      shop:
        unavailable_pack:
          title: 'erreur'
          message: 'pack indisponible'
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
          connection: 'Il est impossible de contacter le serveur. Veuillez vérifier votre connexion internet.'
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
          invitation_text: 'accepte'
    view:
      outgame:
        login:
          already_email: "Un email vient d'être envoyé à {0} avec le code a renseigner."
          already_facebook: "Email déjà enregistré avec un compte facebook, on lance la connection facebook"
      game:
        questions:
          masked_one: "l'un ou l'autre"
          one_or_another: "l'un ou l'autre"
        stage_1:
          welcome: "Bienvenue aux 4 candidats qui vont jouer aujourd'hui à {0}. Tout de suite première question"
          bad_answer_1hp_bot: "C'est une mauvaise réponse. {0} passe à l'orange"
          bad_answer_1hp_player: "C'est une mauvaise réponse. {0} passe à l'orange"
          bad_answer_0hp_bot: "C'est une deuxième erreur de {0} qui le fait passer au rouge et ... qui dit rouge dit DUEL!"
          bad_answer_0hp_player: "C'est une deuxième erreur qui te fait passer au rouge et ... qui dit rouge dit DUEL!"
          timeout_player: "C'est une absence de réponse. {0} passe à l'orange"
          good_answer: "Bonne réponse. C'est maintenant au tour de {0}"
          pick: "Choisis le joueur que tu veux affronter."
        duel1:
          player_dueled: "{0} t'a défié pour ce duel!"
          bot_dueled: "Le duel oppose {0} à {1}! Le thème choisi par {1} est: {2}"
          lost_bot: "Malheureusement ce n'est pas la bonne réponse pour {0}!"
          lost_player: "Malheureusement ce n'est pas la bonne réponse!"
          won_bot: "{0} remporte son duel pour continuer à jouer à la manche suivante."
          won_player: "Ce duel remporté vous permet de continuer à jouer pour la manche suivante."
          next: "suivant"
          timeout_player: "Trop tard!"
          timeout_bot: "Trop tard!"
          finish: "A l'issue du coup d'envoi, {0} est éliminé et nos trois autres candidats sont sélectionnés pour le Coup par coup!"
          finish_2: "A l'issue du coup d'envoi, tu es éliminé et nos trois autres candidats sont sélectionnés pour le Coup par coup!"
        stage_2:
          welcome: "Vous êtes trois dans un instant vous ne serez plus que deux autour de l'étoile. Attention première question!"
          bad_answer_1hp_bot: "Et non! {1} était l'intrus! {0} passe à l'orange."
          bad_answer_1hp_player: "Et non! {1} était l'intrus! {0} passe à l'orange."
          bad_answer_0hp_bot: "Cette 2ème erreur fait passer {0} au rouge."
          bad_answer_0hp_player: "Cette 2ème erreur fait passer {0} au rouge."
          no_more_proposition: "Bravo à vous 3 c'est un coup parfait, question suivante!"
          pick: "Choisis le joueur que tu veux affronter."
        duel2:
          player_dueled: "{0} t'a défié pour ce duel!"
          bot_dueled: "Le duel oppose {0} à {1}! Le thème choisi par {1} est: {2}"
          lost_bot: "Malheureusement ce n'est pas la bonne réponse pour {0}!"
          won_bot: "{0} remporte son duel pour continuer à jouer à la manche suivante."
          lost_player: "Quel dommage {0}, ce n'est pas la bonne réponse! Ta prochaine participation sera sans doute couronnée de succès."
          won_player: "Ce duel remporté vous permet de continuer à jouer pour la manche suivante."
          next: "suivant"
          timeout_player: "Trop tard!"
          timeout_bot: "Trop tard!"
          finish: "Félicitations à nos deux candidats qui vont s'affronter maintenant en Coup fatal!"
          finish_2: "A l'issue du Coup par Coup, tu es éliminé et nos deux autres candidats sont sélectionnés pour le Coup fatal!"
        stage_3:
          welcome: "Qui sera Maître de Midi dans un instant ? C'est un face à face au sommet entre nos deux meilleurs candidats: voici le Coup fatal!"
          master_won: "Le chrono de {0} est à zéro. Félicitations à {1} qui reste Maître de Midi!"
          master_lost: "Le chrono de {0} est à zéro. Félicitations à {1} qui devient Maître de Midi!"
          wait: "{0} est en train de répondre..."
          finish_lost: "Quel dommage d'échouer si près du but mais la prochaine fois sera probablement la bonne!"
          finish_won: "Tu vas maintenant pouvoir tenter de réaliser un Coup de maître!"
        stage_4:
          welcome: "Bravo, tu es rang {0}! Tu joues pour un coup de Maître à {1}! Tente de tout faire pour les garder!"
          good_answer: "Ta bonne réponse te permet de garder tes {0}!"
          bad_answer: "Ce n'était pas la bonne réponse! Ta cagnotte passe à {0}"
          fourth_good_answer: "Plus qu'une question pour réaliser un coup de Maître!"
          master_piece: "Félicitations! C'est un coup de maître à {0} que tu viens de remporter!!!"
          not_master_piece: "Tes {1} bonnes réponses te permettent de remporter une cagnotte de {0} et de dévoiler {1} cases sur l'étoile mystérieuse!"
          finish: "Tout de suite l'Etoile Mystérieuse!"
        stage_5:
          discover: "Grâce à tes bonnes réponses {0} cases ont été dévoilées sur l'Etoile Mystérieuse. Bonne chance!"
          discover_1: "Attention, plus que quelques secondes avant de répondre!"
          answer: "{0}, il vous reste {1} secondes pour donner une réponse"
          good_answer: "Bravo! En dévoilant l'Etoile Mystérieuse tu remportes un bonus de {0} désormais ta cagnotte s'élève à {1}"
          bad_answer: "Malheureusement ce n'était pas {0}. Il faudra retenter ta chance la prochaine fois!"
          timeout: "Message en cas de timeout a definir"
      invitaion:
        facebook: "1 partie par invitaion unique d'amis dans la limite de 10/semaine"
        twitter: "1 jeton par invitaion dans la limite de 10 jetons au total"
        mail: "1 jeton par invitaion dans la limite de 10 jetons au total"
        sms: "1 jeton par invitaion dans la limite de 10 jetons au total"
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
