module ApplicationHelper
  def format_laptime(laptime)
    minutes = laptime / 60000
    seconds = (laptime % 60000) / 1000.0
    format("%d:%06.3f", minutes, seconds)  # Formata como "m:ss.sss"
  end
end
