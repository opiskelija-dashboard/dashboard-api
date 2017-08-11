class BadgesController < ApplicationController
  def get_all_badges
    ret = {
      "badges":[
        {"nimi": "ansiomerkki1"},
        {"nimi": "ansiomerkki2"},
        {"nimi": "ansiomerkki3"},
        {"nimi": "ansiomerkki4"},
        {"nimi": "ansiomerkki5"},
        {"nimi": "ansiomerkki6"}
      ]
    }

    render json: ret
  end


end
