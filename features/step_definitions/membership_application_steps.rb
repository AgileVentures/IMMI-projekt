And(/^the following applications exist:$/) do |table|
 table.hashes.each do |hash|
   attributes = hash.except('user_email', 'categories', 'company_name')
   user = User.find_by(email: hash[:user_email].downcase)

   if hash['state'] == 'accepted' || hash['state'] == 'rejected'

     if hash['company_name']
       company = Company.find_by(name: hash['company_name'])
     else
       company = Company.find_by(company_number: hash['company_number'])
       unless company
         company = FactoryBot.create(:company, company_number: hash['company_number'])
       end
     end
   end
   contact_email = hash['contact_email'] && ! hash['contact_email'].empty? ?
                   hash['contact_email'] : hash[:user_email]

   if company.nil?
     company_number = hash['company_number']
   else
     company_number = company.company_number
   end

   ma = FactoryBot.create(:shf_application,
                            attributes.merge(user: user,
                            company_number: company_number,
                            contact_email: contact_email))

   if hash['categories']
     categories = []
     for category_name in hash['categories'].split(/\s*,\s*/)
       categories << BusinessCategory.find_by_name(category_name)
     end
     ma.business_categories = categories
   end
 end
end
