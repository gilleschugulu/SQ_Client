var AssetsList = {
  assets: { 'common/': ["images/common/background.png", "images/common/home.png", "images/common/timer.png"],
'game-over/': ["images/game-over/popup.png", "images/game-over/popup_victoire.png", "images/game-over/rejouer.png", "images/game-over/rejouer_a.png"],
'hall-of-fame/': ["images/hall-of-fame/adversaire.png", "images/hall-of-fame/adversaires_deactive.png", "images/hall-of-fame/amis.png", "images/hall-of-fame/amis_deactive.png", "images/hall-of-fame/background.jpg", "images/hall-of-fame/fond_classement.png", "images/hall-of-fame/gamecenter.png", "images/hall-of-fame/jeton.png", "images/hall-of-fame/precedent.png", "images/hall-of-fame/rank1.png", "images/hall-of-fame/rank2.png", "images/hall-of-fame/rank3.png", "images/hall-of-fame/rankadversaire.png", "images/hall-of-fame/title.png"],
'home/+2amis/': ["images/home/+2amis/inviter.png", "images/home/+2amis/inviter_a.png", "images/home/+2amis/ranking.png", "images/home/+2amis/ranking_a.png", "images/home/+2amis/title.png"],
'home/1ami/': ["images/home/1ami/invite.png", "images/home/1ami/invite_a.png", "images/home/1ami/player_VS.png", "images/home/1ami/ranking.png", "images/home/1ami/ranking_a.png", "images/home/1ami/title.png"],
'home/2amis/': ["images/home/2amis/invite.png", "images/home/2amis/invite_a.png", "images/home/2amis/podium_rank_bronze.png", "images/home/2amis/podium_rank_gold.png", "images/home/2amis/podium_rank_silver.png", "images/home/2amis/rank_3players.png", "images/home/2amis/ranking.png", "images/home/2amis/ranking_a.png", "images/home/2amis/title.png"],
'home/common/': ["images/home/common/background.jpg", "images/home/common/credit.png", "images/home/common/heart.png", "images/home/common/journal.png", "images/home/common/logo.png", "images/home/common/moregame.png", "images/home/common/options.png", "images/home/common/options_a.png", "images/home/common/play.png", "images/home/common/play_a.png", "images/home/common/profile.png", "images/home/common/profile_a.png", "images/home/common/shop.png", "images/home/common/shop_a.png"],
'home/pasamis/': ["images/home/pasamis/1.png", "images/home/pasamis/100.png", "images/home/pasamis/1000.png", "images/home/pasamis/exclusif.png", "images/home/pasamis/frame_rank.png", "images/home/pasamis/invite.png", "images/home/pasamis/invite_a.png", "images/home/pasamis/photo.png", "images/home/pasamis/rank.png", "images/home/pasamis/ranking_day.png", "images/home/pasamis/spacer.png"],
'ingame/': ["images/ingame/add_time.png", "images/ingame/answer.png", "images/ingame/answer_bad.png", "images/ingame/answer_good.png", "images/ingame/box_bonus.png", "images/ingame/box_question.png", "images/ingame/bt_home.png", "images/ingame/double.png", "images/ingame/fifty_fifty.png", "images/ingame/mass.png", "images/ingame/photo.png", "images/ingame/repere.png", "images/ingame/score.png", "images/ingame/skip.png", "images/ingame/timer.png", "images/ingame/timer_chrono.png", "images/ingame/timer_in.png", "images/ingame/title.png", "images/ingame/title_left.png", "images/ingame/title_question.png"],
'login/': ["images/login/150j.png", "images/login/background.png", "images/login/facebook_login.png", "images/login/facebook_login_a.png", "images/login/facebook_login_gris.png", "images/login/mail_login.png", "images/login/mail_login_a.png", "images/login/ok.png", "images/login/ou.png"],
'more-games/': ["images/more-games/title.png"],
'options/': ["images/options/aide.png", "images/options/aide_a.png", "images/options/background.png", "images/options/credits.png", "images/options/credits_a.png", "images/options/effet.png", "images/options/effet_deactive.png", "images/options/infos.png", "images/options/infos_deactive.png", "images/options/liaison_fb.png", "images/options/liaison_fb_a.png", "images/options/musique.png", "images/options/musique_deactive.png", "images/options/title.png", "images/options/tutoriel.png", "images/options/tutoriel_a.png"],
'pause/': ["images/pause/fx.png", "images/pause/fx_sans.png", "images/pause/musique.png", "images/pause/musique_sans.png", "images/pause/popup.png", "images/pause/quitter.png", "images/pause/quitter_a.png", "images/pause/reprendre.png", "images/pause/reprendre_a.png"],
'profile/': ["images/profile/bloc_infos.png", "images/profile/box_info.png", "images/profile/bt_home.png", "images/profile/cagnottecourante.png", "images/profile/classement.png", "images/profile/eoile.png", "images/profile/etoile.png", "images/profile/framephoto.png", "images/profile/jeton.png", "images/profile/liaison_fb.png", "images/profile/niveaucourant.png", "images/profile/photo_m.png", "images/profile/photo_w.png", "images/profile/pseudo.png", "images/profile/title.png"],
'profile/box/': ["images/profile/box/etoilemysterieure.png", "images/profile/box/meileurniveau.png", "images/profile/box/meilleurecagnotte.png", "images/profile/box/partiesgagnees.png", "images/profile/box/partiesjouees.png"],
'shop/': ["images/shop/aimenous.png", "images/shop/background.jpg", "images/shop/completeoffre.png", "images/shop/historiqueachats.png", "images/shop/home.png", "images/shop/inviter.png", "images/shop/jeton.png", "images/shop/jetonsofferts.png", "images/shop/notelejeu.png", "images/shop/pack_lameilleureoffre.png", "images/shop/pack_lepluspopulaire.png", "images/shop/pack_mediumpack.png", "images/shop/pack_minipack.png", "images/shop/regardervideo.png", "images/shop/title.png"] },
  keys: {
    profile: ['profile', 'common'],
    home: ['home/1ami', 'home/2amis/', 'home/common/', 'home/pasamis/', 'home/+2amis'],
    invitation: ['invitation', 'common'],
    options: ['options'],
    'more-games': ['more-games', 'common'],
    'hall-of-fame': ['hall-of-fame'],
    stage_1: ['star-stage', 'common', 'star', 'duel', 'avatar', 'desk'],
    stage_duel: ['star-stage', 'duel', 'common', 'avatar', 'desk'],
    stage_2: ['star-stage', 'common', 'star', 'duel', 'avatar', 'desk'],
    stage_3: ['common']
  }
};
