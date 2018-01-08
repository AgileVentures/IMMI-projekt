# Required to communicate with Dinkurs.se via the DinkursService object
#
# This gets information from ENV either the .env file or the actual environment via the dotenv gem.

require 'dotenv'

DINKURS_XML_URL =   ENV['DINKURS_XML_URL']

DINKURS_COMPANY_ARG = ENV['DINKURS_URL_COMPANY_ARG']
