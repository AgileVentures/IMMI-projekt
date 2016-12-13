module ApplicationHelper
  def flash_class(level)
    case level.to_sym
      when :notice then 'success'
      when :alert then 'danger'
    end
  end

  def flash_message(type, text)
    flash[type] ||= []
    if flash[type].instance_of? String
      flash[type] = [flash[type]]
    end
    flash[type] << text
  end

  def render_flash_message(flash_value)
    if flash_value.instance_of? String
      flash_value
    else
      safe_join(flash_value, '<br/>'.html_safe)
    end
  end

  # ActiveRecord::Assocations::CollectionAssociation is a proxy and won't
  # always load info. see the class documentation for more info
  def assocation_empty?(assoc)
    assoc.reload unless assoc.nil? || assoc.loaded?
    assoc.nil? ? true : assoc.size == 0
  end
end
