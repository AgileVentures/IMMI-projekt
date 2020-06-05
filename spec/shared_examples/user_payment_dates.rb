RSpec.shared_examples 'it finds the right number of membership expires for date' do |x_days, num_found, on_date|

  it "expires in #{x_days} days (#{on_date}) finds #{num_found}" do
    expire_today = User.membership_expires_in_x_days(x_days).pluck(:expire_date)
    expect(expire_today.count).to eq num_found
    expect(expire_today.uniq.count).to eq 1
    expect(expire_today.uniq.first).to eq(on_date)
  end
end

RSpec.shared_examples 'it finds the right number of branding fee expires for date' do |x_days, num_found, on_date|

  it "expires in #{x_days} days (#{on_date}) finds #{num_found}" do
    expire_today = User.company_hbrand_expires_in_x_days(x_days).pluck(:expire_date)
    expect(expire_today.count).to eq num_found
    expect(expire_today.uniq.count).to eq 1
    expect(expire_today.uniq.first).to eq(on_date)
  end
end
