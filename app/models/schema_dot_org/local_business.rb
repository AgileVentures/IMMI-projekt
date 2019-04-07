#!/usr/bin/ruby

#--------------------------
#
# @class LocalBusiness
#         https://schema.org/LocalBusiness
#   This is just a subset of the properties of the schema.org LocalBusiness type
#
# @desc Responsibility: "A particular physical business or branch of an organization.
#                        Examples of LocalBusiness include a restaurant, a particular
#                        branch of a restaurant chain, a branch of a bank,
#                        a medical practice, a club, a bowling alley, etc."
#
#   see https://developers.google.com/search/docs/data-types/local-business
#   see https://support.google.com/webmasters/answer/2774099
#
#   see http://wiki.goodrelations-vocabulary.org/Quickstart
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-19
#
# @file local_business.rb
#
#--------------------------

module SchemaDotOrg

  class LocalBusiness < Organization
  end

end
