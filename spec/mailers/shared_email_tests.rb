require 'email_spec/rspec'

# assumes that 'email_created' exists e.g. via a let(:..) (which might be within a block)
RSpec.shared_examples 'a successfully created email' do | subject, recipient, greeting |

  it 'subject is correct' do
    expect(email_created).to have_subject( subject )
  end

  it 'recipient is correct' do
    expect(email_created).to deliver_to( recipient )
  end

  it 'greeting is correct' do
    expect(email_created).to have_body_text( greeting )
  end

end
