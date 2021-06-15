object @image
attributes :id,:type
node(:large_url) { |i| i.attachment.url(:large) }
