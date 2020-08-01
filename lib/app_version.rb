# @class AppVersion Gets the application version
#     Read the REVISION file and set the version to 'revision <whatever is in REVISION file>'
#     If there is no REVISION file, set the version to '1.0.0 <revision unknown>'
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2020-07-10
#

class AppVersion

  DEFAULT_VERSION = '1.0.0 <revision unknown>'
  REVISION_FN = 'REVISION'

  # ============================================================================


  def self.get_version(revision_path = '.')

    rev_file_path = File.join(revision_path, REVISION_FN)
    version = if File.exist?(rev_file_path)
                # File mode rb:bom|utf-8 means 'read-only (r) binary (b) with ( binary mode encoded (bom) OR utf-8 encoded)'
                "revision #{File.open(rev_file_path, 'rb:bom|utf-8', &:read)}"
              else
                DEFAULT_VERSION
              end

    version.strip
  end


end
