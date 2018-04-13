# https://cucumber.io/blog/2017/07/26/announcing-cucumber-expressions

CAPTURE_STRING = '((?:t\(".*\)|"[^"]*"))'

ParameterType(
  name: 'capture_string',
  regexp: Regexp.new(CAPTURE_STRING),
  transformer: lambda do |content|
    needs_translation = content[0] == 't'
    unless needs_translation
      content[1..-2]
    else
      cleaned_content = content.delete("\"'")[2..-2]
      key, parameters = parse_i18n_string(cleaned_content)
      Rails::Html::FullSanitizer.new.sanitize(i18n_content(key, parameters))
      # ^ strip html styling tags in i18n string (otherwise comparison of the
      #   string to the rendered version will fail)
    end
  end
)

ParameterType(
  name: 'negate',
  regexp: /( not|)/,
  transformer: -> (str) { str.empty? ? nil : str }
)

ParameterType(
  name: 'optional_string',
  regexp: /( the \w*| \w*|)/,
  transformer: lambda do |str|
    str = str.sub(' the', '')
    str.empty? ? nil : str.lstrip
  end
)

ParameterType(
  name: 'ordinal',
  regexp: /(first|second|third|fourth)/,
  transformer: -> (str) { str }
)

ParameterType(
  name: 'action',
  regexp: /(check|uncheck)/,
  transformer: -> (str) { str }
)

ParameterType(
  name: 'digits',
  regexp: /(\d+)/,
  transformer: -> (str) { str.to_i }
)

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

      # Parameters other than strings can be handled by specifying a
      # string transformation method in the cucumber step, e.g.:
      #  Then I should see t("my_company", count: '1.to_i')
      if (idx = value.index('.to_'))
        value = value[0..idx-1].send(value[idx+1..-1])
      end
      parameters[key] = value
    end
  end

  return i18n_key, parameters
end
