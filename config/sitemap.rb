# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://hitta.sverigeshundforetagare.se"

SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do

  # Default version (and URLs) is the Swedish (svenska) version:
  group(filename: :svenska) do

    add root_path, changefreq: 'daily', priority: 0.8

    Company.find_each do |co|
      add company_path(co), lastmod: co.updated_at, changefreq: 'weekly'
    end
  end


  # English version:
  # pass in 'locale: :en' to  each path to get the English version
  group(filename: :english) do

    add root_path(locale: :en), changefreq: 'daily', priority: 0.7

    Company.find_each do |co|
      add company_path(co, locale: :en), lastmod: co.updated_at, changefreq: 'weekly'
    end
  end
end