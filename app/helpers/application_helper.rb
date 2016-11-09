module ApplicationHelper

  def flash_class(level)
    case level.to_sym
      when :notice then 'success'
      when :alert then 'danger'
    end
  end
end
