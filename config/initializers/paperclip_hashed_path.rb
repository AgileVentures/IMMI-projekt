Paperclip.interpolates :hashed_path do |attachment, style|
  secret = 'Ac}SErVlnyhSty9TbEaWb^uedgoFqdKWZhwyKqVT'
  hash = Digest::MD5.hexdigest("--#{attachment.class.name}--#{attachment.instance.id}--#{secret}--")
  hash_path = ''
  6.times { hash_path += '/' + hash.slice!(0..2) }
  hash_path[1..24]
end
