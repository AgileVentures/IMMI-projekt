
CAPTURE_STRING = '((?:t\(".*\)|"[^"]*"))'

Transform (/^#{CAPTURE_STRING}$/) do | content |
  needs_translation = content[0] == 't'
  unless needs_translation
    content[1..-2]
  else
    cleaned_content = content.delete("\"'")[2..-2]
    key, parameters = parse_i18n_string(cleaned_content)
    i18n_content(key, parameters)
  end
end

def parse_i18n_string(i18n_string)
  i18n_key = i18n_string
  parameters = {}

  separator = i18n_string.index(',')
  if separator
    i18n_key = i18n_string[0..separator-1]
    parameters_array = i18n_string[separator+1..-1].split(',')

    parameters_array.each do |e|
      keyvalue = e.sub(' :', ' ').split(':')
      key = keyvalue[0].strip.to_sym
      value = keyvalue[1].strip
      parameters[key] = value
    end
  end

  return i18n_key, parameters
end

