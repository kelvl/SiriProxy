require 'mkmf'

extension_name = 'speexdec'

dir_config(extension_name)

have_library('speex')

create_makefile(extension_name)