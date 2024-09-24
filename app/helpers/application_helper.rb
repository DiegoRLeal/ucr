module ApplicationHelper
  def format_laptime(laptime)
    minutes = laptime / 60000
    seconds = (laptime % 60000) / 1000.0
    format("%d:%06.3f", minutes, seconds)  # Formata como "m:ss.sss"
  end

  def format_track_name(track_name)
    track_name.split('_').map(&:capitalize).join(' ')
  end
end
