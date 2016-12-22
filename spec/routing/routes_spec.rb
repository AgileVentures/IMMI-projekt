require 'rails_helper'

RSpec.shared_examples "a swedish named resource" do |swedish_name, controller|

  let(:new)  { 'ny' }
  let(:edit) { 'redigera' }

  it "/#{swedish_name} = #index" do
    assert_routing({path: "#{swedish_name}", method: :get}, {controller: controller, action: 'index'})
  end

  it "/#{swedish_name}/ny = #create" do
    assert_routing({path: "#{swedish_name}", method: :post}, {controller: controller, action: 'create'})
  end

  it "/#{swedish_name}/ny = #new" do
    assert_routing({path: "#{swedish_name}/#{new}", method: :get}, {controller: controller, action: 'new'})
  end

  it "/#{swedish_name}/i/redigera = #edit" do
    assert_routing({path: "#{swedish_name}/1/#{edit}", method: :get}, {controller: controller, action: 'edit', id: '1'})
  end

  it "/#{swedish_name}/i = #show" do
    assert_routing({path: "#{swedish_name}/1", method: :get}, {controller: controller, action: 'show', id: '1'})
  end

  it "/#{swedish_name}/i = #update" do
    assert_routing({path: "#{swedish_name}/1", method: :patch}, {controller: controller, action: 'update', id: '1'})
  end

  it "/#{swedish_name}/i = #update" do
    assert_routing({path: "#{swedish_name}/1", method: :put}, {controller: controller, action: 'update', id: '1'})
  end

  it "/#{swedish_name}/i = #destroy" do
    assert_routing({path: "#{swedish_name}/delete", method: :delete}, {controller: controller, action: 'destroy', id: 'delete'})
  end

end



RSpec.describe "swedish named routes", :type => :routing do

  describe 'companies path = hundforetag, controller: CompaniesController' do

    it_should_behave_like "a swedish named resource", 'hundforetag', 'companies'

  end


  describe 'membership_applications path = ansokan, controller: MembershipApplicationsController' do

    it_should_behave_like "a swedish named resource", 'ansokan', 'membership_applications'

  end


  describe 'business_categories path = kategori, controller: BusinessCategoriesController' do

    it_should_behave_like "a swedish named resource", 'kategori', 'business_categories'

  end


end
