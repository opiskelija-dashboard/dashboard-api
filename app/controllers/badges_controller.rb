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

  def initialize
    @point_source = Rails.configuration.points_store_class == 'MockPointsStore' ? MockPointsStore : PointsStore
    @badge_source = Rails.configuration.badge_store_class == 'MockBadgeStore' ? MockBadgeStore : BadgeStore
  end

  def get_user_awarded_badges
    course_id = params["course_id"].to_s
    @badge_source.
  end

  def update_points_source_if_necessary(course_id, token)
    unless @point_source.has_course_points?(course_id)
      Rails.logger.debug("PointsStore didn't have points of course " + course_id + ", fetching...");
      @point_source.update_course_points(course_id, token)
    end
  end

