require 'rails_helper'

require 'shared_examples/check_env_vars'

require 'timecop'

NOTIFICATION_SOURCE = 'test task'


# ===============================================================

RSpec.shared_examples "it has a default and allows custom text" do |default_text, tested_method|

  it "default is '#{default_text}'" do

    expect(SHFNotifySlack).to receive(:notification)
                                  .with(NOTIFICATION_SOURCE,
                                        default_text,
                                        any_args)

    SHFNotifySlack.send(tested_method, NOTIFICATION_SOURCE)
  end

  it 'can specify custom notification text' do

    custom_notification_text = 'some informative text to show in Slack'

    expect(SHFNotifySlack).to receive(:notification)
                                  .with(NOTIFICATION_SOURCE,
                                        custom_notification_text,
                                        any_args)


    SHFNotifySlack.send(tested_method, NOTIFICATION_SOURCE, text: custom_notification_text)
  end

end


RSpec.shared_examples "it has a default and allows a custom emoji" do |default_emoji, tested_method|

  it "default emoji is '#{default_emoji}'" do

    expect(SHFNotifySlack).to receive(:notification)
                                  .with(anything, anything,
                                        hash_including(emoji: default_emoji))

    SHFNotifySlack.send(tested_method, NOTIFICATION_SOURCE)
  end

  it 'can specify a custom emoji' do

    custom_emoji = ':nerd_face:'

    expect(SHFNotifySlack).to receive(:notification)
                                  .with(anything, anything,
                                        hash_including(emoji: custom_emoji))


    SHFNotifySlack.send(tested_method, NOTIFICATION_SOURCE, emoji: custom_emoji)
  end

end


RSpec.shared_examples "it has a default and allows a custom color" do |default_color, tested_method|

  it "default color is '#{default_color}'" do

    expect(SHFNotifySlack).to receive(:notification)
                                  .with(anything, anything,
                                        hash_including(color: default_color))

    SHFNotifySlack.send(tested_method, NOTIFICATION_SOURCE)
  end

  it 'can specify a custom color' do

    custom_color = '#404040'

    expect(SHFNotifySlack).to receive(:notification)
                                  .with(anything, anything,
                                        hash_including(color: custom_color))


    SHFNotifySlack.send(tested_method, NOTIFICATION_SOURCE, color: custom_color)
  end

end


# ===============================================================

RSpec.describe 'SHFNotifySlack', type: :model do

  before(:all) do
    # send the notifications to the _testing_ channel
    RSpec::Mocks.with_temporary_scope do
      # must stub this way so the rest of ENV is preserved
      stub_const('ENV', ENV.to_hash.merge({ 'SHF_SLACK_CHANNEL' => 'notification_testing' }))
    end
  end


  it_behaves_like 'expected ENV variables exist', %w(SHF_SLACK_WEBHOOKURL SHF_SLACK_CHANNEL
                                                   SHF_SLACK_USERNAME)

  describe '.notify_after do <block> ...' do

    it 'notification source cannot be nil' do

      expect {
        SHFNotifySlack.notify_after(nil) { true }
      }.to raise_error ArgumentError
    end


    context 'no error is raised; the block of code runs fine:' do

      it 'sends success_notification if the code runs fine' do

        expect(SHFNotifySlack).to receive(:success_notification)
                                      .with(NOTIFICATION_SOURCE, anything)
                                      .and_return(true)

        SHFNotifySlack.notify_after(NOTIFICATION_SOURCE) do
          true
        end
      end

      it "default success text is 'Successful'" do
        expect(SHFNotifySlack).to receive(:success_notification)
                                      .with(NOTIFICATION_SOURCE,
                                            hash_including(text: 'Successful'))
                                      .and_return(true)

        SHFNotifySlack.notify_after(NOTIFICATION_SOURCE) do
          true
        end
      end

      it 'can pass in custom text to use when it calls success_notification' do

        custom_text = 'custom notification text when successful'

        expect(SHFNotifySlack).to receive(:success_notification)
                                      .with(NOTIFICATION_SOURCE,
                                            hash_including(text: custom_text))
                                      .and_return(true)

        SHFNotifySlack.notify_after(NOTIFICATION_SOURCE, success_text: custom_text) do
          true
        end
      end


      it "default success emoji is ':white_check_mark:'" do

        expect(SHFNotifySlack).to receive(:success_notification)
                                      .with(NOTIFICATION_SOURCE,
                                            hash_including(emoji: ':white_check_mark:'))
                                      .and_return(true)

        SHFNotifySlack.notify_after(NOTIFICATION_SOURCE) do
          true
        end
      end

      it 'can pass in a custom emoji to use when it calls success_notification' do

        custom_emoji = ':nerd_face:'

        expect(SHFNotifySlack).to receive(:success_notification)
                                      .with(NOTIFICATION_SOURCE,
                                            hash_including(emoji: custom_emoji))
                                      .and_return(true)

        SHFNotifySlack.notify_after(NOTIFICATION_SOURCE, success_emoji: custom_emoji) do
          true
        end
      end

    end # context 'no error is raised; code runs fine'


    context 'an error is raised; the block fails in some way' do

      it 'sends failure_notification if an error is raised' do

        expect(SHFNotifySlack).to receive(:failure_notification)
                                      .with(NOTIFICATION_SOURCE, anything)
                                      .and_return(true)

        expect {
          SHFNotifySlack.notify_after(NOTIFICATION_SOURCE) do
            raise StandardError
          end
        }.to raise_error StandardError

      end


      it 'raises the error that happened' do
        allow(SHFNotifySlack).to receive(:failure_notification)
                                      .with(NOTIFICATION_SOURCE, anything)
                                      .and_return(true)

        expect {
          SHFNotifySlack.notify_after(NOTIFICATION_SOURCE) do
            raise IOError
          end
        }.to raise_error IOError

      end

      it "default failure text is 'Failure!' with the raised error message " do

        expect(SHFNotifySlack).to receive(:failure_notification)
                                      .with(NOTIFICATION_SOURCE,
                                            hash_including(text: "Failure! The error message"))

        expect {
          SHFNotifySlack.notify_after(NOTIFICATION_SOURCE) do
            raise StandardError.new('The error message')
          end
        }.to raise_error StandardError

      end


      it 'can pass in custom text to use when it calls failure_notification' do

        custom_text = 'custom notification text when failure happens'

        expect {
          SHFNotifySlack.notify_after(NOTIFICATION_SOURCE, failure_text: custom_text) do
            raise StandardError
          end
        }.to raise_error StandardError

        expect(SHFNotifySlack).to receive(:failure_notification)
                                      .with(NOTIFICATION_SOURCE,
                                            hash_including(text: "#{custom_text} The error message"))

        expect {
          SHFNotifySlack.notify_after(NOTIFICATION_SOURCE,
                                      failure_text: custom_text) do
            raise StandardError.new('The error message')
          end
        }.to raise_error StandardError


      end

      it "default failure emoji is ':x:'" do

        expect(SHFNotifySlack).to receive(:failure_notification)
                                      .with(NOTIFICATION_SOURCE,
                                            hash_including(emoji: ':x:'))
                                      .and_return(true)

        expect {
          SHFNotifySlack.notify_after(NOTIFICATION_SOURCE) do
            raise StandardError
          end
        }.to raise_error StandardError
      end

      it 'can pass in a custom emoji to use when it calls failure_notification' do

        custom_emoji = ':nerd_face:'

        expect(SHFNotifySlack).to receive(:failure_notification)
                                      .with(NOTIFICATION_SOURCE,
                                            hash_including(emoji: custom_emoji))
                                      .and_return(true)

        expect {
          SHFNotifySlack.notify_after(NOTIFICATION_SOURCE, failure_emoji: custom_emoji) do
            raise StandardError
          end
        }.to raise_error StandardError
      end

    end # context 'an error is raised'

  end #  describe '.notify_after do <block> ...'


  describe '.success_notification' do

    success_notification_method = :success_notification


    describe 'notification text' do
      it_behaves_like "it has a default and allows custom text", 'Successful', success_notification_method
    end

    describe 'emoji' do
      it_behaves_like "it has a default and allows a custom emoji", ':white_check_mark:', success_notification_method
    end

  end


  describe '.failure_notification' do

    failure_notification_method = :failure_notification


    describe 'notification text' do
      it_behaves_like "it has a default and allows custom text", 'Failure!', failure_notification_method
    end

    describe 'emoji' do
      it_behaves_like "it has a default and allows a custom emoji", ':x:', failure_notification_method
    end

  end


  describe '.notification' do

    it "sends via Slack webhook ENV['SHF_SLACK_WEBHOOKURL']" do

      # the ENV must be defined for testing
      expect(ENV.to_hash.fetch('SHF_SLACK_WEBHOOKURL', nil)).not_to be_nil
      slack_webhook = ENV['SHF_SLACK_WEBHOOKURL']

      slack_notifier_dbl = double("slack_notifier")
      expect(Slack::Notifier).to receive(:new)
                                     .with(slack_webhook, anything)
                                     .and_return(slack_notifier_dbl)

      allow(slack_notifier_dbl).to receive(:post)
                                       .with(anything).and_return(true)

      SHFNotifySlack.notification(NOTIFICATION_SOURCE, 'some text')
    end

    it "sends to Slack channel ENV['SHF_SLACK_CHANNEL']" do

      # the ENV must be defined for testing
      expect(ENV.to_hash.fetch('SHF_SLACK_CHANNEL', nil)).not_to be_nil
      slack_channel = ENV['SHF_SLACK_CHANNEL']

      slack_notifier_dbl = double("slack_notifier")

      expect(Slack::Notifier).to receive(:new)
                                     .with(anything,
                                           hash_including(channel: slack_channel))
                                     .and_return(slack_notifier_dbl)

      allow(slack_notifier_dbl).to receive(:post)
                                       .with(anything).and_return(true)

      SHFNotifySlack.notification(NOTIFICATION_SOURCE, 'some text')
    end


    it "sends ENV['SHF_SLACK_USERNAME'] as the username " do

      # the ENV must be defined for testing
      expect(ENV.to_hash.fetch('SHF_SLACK_USERNAME', nil)).not_to be_nil

      slack_username = ENV['SHF_SLACK_USERNAME']

      slack_notifier_dbl = double("slack_notifier")

      expect(Slack::Notifier).to receive(:new)
                                     .with(anything,
                                           hash_including(username: slack_username))
                                     .and_return(slack_notifier_dbl)

      allow(slack_notifier_dbl).to receive(:post)
                                       .with(anything).and_return(true)

      SHFNotifySlack.notification(NOTIFICATION_SOURCE, 'some text')
    end

    it "sends details in the single attachments hash" do

      slack_notifier_dbl = double("slack_notifier")
      allow(Slack::Notifier).to receive(:new).and_return(slack_notifier_dbl)

      test_time = DateTime.civil_from_format(:utc, 2018)
      Timecop.freeze(test_time) do

        expected_text       = "some text #{test_time.strftime('%F %T UTC')}"
        expected_attachment = { color:    "#439FE0",
                                fallback: expected_text,
                                footer:   "SHF: test task",
                                title:    expected_text,
                                ts:       test_time.to_i }

        expect(slack_notifier_dbl).to receive(:post)
                                          .with(hash_including(attachments: [expected_attachment]))

        SHFNotifySlack.notification(NOTIFICATION_SOURCE, 'some text')
      end # Timecop
    end


    describe 'text' do

      it 'can be nil' do

        slack_notifier_dbl = double("slack_notifier")
        allow(Slack::Notifier).to receive(:new).and_return(slack_notifier_dbl)

        test_time = DateTime.civil_from_format(:utc, 2018)
        Timecop.freeze(test_time) do

          expected_text       = " #{test_time.strftime('%F %T UTC')}"
          expected_attachment = { color:    "#439FE0",
                                  fallback: expected_text,
                                  footer:   "SHF: test task",
                                  title:    expected_text,
                                  ts:       test_time.to_i }

          expect(slack_notifier_dbl).to receive(:post)
                                            .with(hash_including(attachments: [expected_attachment]))

          SHFNotifySlack.notification(NOTIFICATION_SOURCE, nil)
        end # Timecop
      end

      it 'can be an empty string' do

        slack_notifier_dbl = double("slack_notifier")
        allow(Slack::Notifier).to receive(:new).and_return(slack_notifier_dbl)

        test_time = DateTime.civil_from_format(:utc, 2018)
        Timecop.freeze(test_time) do

          expected_text       = " #{test_time.strftime('%F %T UTC')}"
          expected_attachment = { color:    "#439FE0",
                                  fallback: expected_text,
                                  footer:   "SHF: test task",
                                  title:    expected_text,
                                  ts:       test_time.to_i }

          expect(slack_notifier_dbl).to receive(:post)
                                            .with(hash_including(attachments: [expected_attachment]))

          SHFNotifySlack.notification(NOTIFICATION_SOURCE, '')
        end # Timecop
      end

      it 'is the main text shown in the notification' do
        slack_notifier_dbl = double("slack_notifier")
        allow(Slack::Notifier).to receive(:new).and_return(slack_notifier_dbl)

        test_time = DateTime.civil_from_format(:utc, 2018)
        Timecop.freeze(test_time) do

          expected_text       = "This is the text shown #{test_time.strftime('%F %T UTC')}"
          expected_attachment = { color:    "#439FE0",
                                  fallback: expected_text,
                                  footer:   "SHF: test task",
                                  title:    expected_text,
                                  ts:       test_time.to_i }

          expect(slack_notifier_dbl).to receive(:post)
                                            .with(hash_including(attachments: [expected_attachment]))

          SHFNotifySlack.notification(NOTIFICATION_SOURCE, 'This is the text shown')
        end # Timecop
      end

    end # text


    describe 'source of the notification' do

      it 'cannot be nil' do
        expect { SHFNotifySlack.notification(nil, 'some text') }.to raise_error ArgumentError
      end

      it 'cannot be an empty string' do
        expect { SHFNotifySlack.notification('', 'some text') }.to raise_error ArgumentError
      end

      it 'is shown in the footer of the notification' do
        slack_notifier_dbl = double("slack_notifier")
        allow(Slack::Notifier).to receive(:new).and_return(slack_notifier_dbl)

        test_time = DateTime.civil_from_format(:utc, 2018)
        Timecop.freeze(test_time) do

          expected_text       = "some text #{test_time.strftime('%F %T UTC')}"
          expected_attachment = { color:    "#439FE0",
                                  fallback: expected_text,
                                  footer:   "SHF: this is the source",
                                  title:    expected_text,
                                  ts:       test_time.to_i }

          expect(slack_notifier_dbl).to receive(:post)
                                            .with(hash_including(attachments: [expected_attachment]))

          SHFNotifySlack.notification('this is the source', 'some text')
        end # Timecop
      end

    end


    describe 'emoji' do

      it 'default emoji is :white_check_mark:' do

        slack_notifier_dbl = double("slack_notifier")
        allow(Slack::Notifier).to receive(:new).and_return(slack_notifier_dbl)

        expect(slack_notifier_dbl).to receive(:post)
                                          .with(hash_including(icon_emoji: ':white_check_mark:'))

        SHFNotifySlack.notification(NOTIFICATION_SOURCE, 'some text')
      end

      it 'can specify a custom emoji' do

        custom_emoji = ':nerd_face:'

        slack_notifier_dbl = double("slack_notifier")
        allow(Slack::Notifier).to receive(:new).and_return(slack_notifier_dbl)

        expect(slack_notifier_dbl).to receive(:post)
                                          .with(hash_including(icon_emoji: custom_emoji))

        SHFNotifySlack.notification(NOTIFICATION_SOURCE, 'some text',
                                    emoji: custom_emoji)
      end
    end # emoji


    describe 'color' do

      # stub out calls to Slack::Notifier
      before do
        slack_notifier_dbl = double("slack_notifier")
        allow(Slack::Notifier).to receive(:new).and_return(slack_notifier_dbl)
        allow(slack_notifier_dbl).to receive(:post).and_return(true)
      end


      it 'default color is #439FE0' do
        expect(SHFNotifySlack).to receive(:make_details)
                                      .with(anything, anything,
                                            hash_including(color: '#439FE0'))
                                      .and_call_original

        SHFNotifySlack.notification(NOTIFICATION_SOURCE, 'some text')
      end

      it 'can specify a custom color' do

        custom_color = '#404040'
        expect(SHFNotifySlack).to receive(:make_details)
                                      .with(anything, anything,
                                            hash_including(color: custom_color))

        SHFNotifySlack.notification(NOTIFICATION_SOURCE, 'some text',
                                    color: custom_color)
      end
    end # color

  end # notification


  describe 'make_details creates the Hash that Slack expects' do

    it 'default values: text is ampty string, color is blue' do
      test_time = DateTime.civil_from_format(:utc, 2018)
      Timecop.freeze(test_time) do

        expected_title = " #{test_time.strftime("%F %T UTC")}"

        expect(SHFNotifySlack.make_details(NOTIFICATION_SOURCE))
            .to eq({ color:    '#439FE0',
                     fallback: expected_title,
                     title:    expected_title,
                     footer:   "SHF: #{NOTIFICATION_SOURCE}",
                     ts:       test_time.to_i })
      end # Timecop
    end


    it 'notification source cannot be nil' do
      expect { SHFNotifySlack.make_details(nil) }.to raise_error ArgumentError
    end

    it 'notification source cannot be an empty String' do
      expect { SHFNotifySlack.make_details('') }.to raise_error ArgumentError
    end

    it 'text is the title for the notification' do

      test_time = DateTime.civil_from_format(:utc, 2018)
      Timecop.freeze(test_time) do

        text_to_show   = 'some text'
        expected_title = "#{text_to_show} #{test_time.strftime("%F %T UTC")}"

        details = SHFNotifySlack.make_details(NOTIFICATION_SOURCE, text_to_show)
        expect(details[:title]).to eq(expected_title)
      end # Timecop
    end

    it 'a UTC timestamp is appended to the text' do
      test_time = DateTime.civil_from_format(:utc, 2018)
      Timecop.freeze(test_time) do

        text_to_show  = 'some text'
        expected_text = "#{text_to_show} #{test_time.strftime("%F %T UTC")}"

        details = SHFNotifySlack.make_details(NOTIFICATION_SOURCE, text_to_show)
        expect(details[:title]).to eq(expected_text)
      end # Timecop
    end

    it 'title and fallback are the same' do
      test_time = DateTime.civil_from_format(:utc, 2018)
      Timecop.freeze(test_time) do
        details = SHFNotifySlack.make_details(NOTIFICATION_SOURCE, 'some text')

        expect(details[:fallback]).to eq(details[:title])
      end # Timecop
    end

    it 'given some text to show' do

      test_time = DateTime.civil_from_format(:utc, 2018)
      Timecop.freeze(test_time) do

        text_to_show   = 'some text'
        expected_title = "#{text_to_show} #{test_time.strftime("%F %T UTC")}"

        expect(SHFNotifySlack.make_details(NOTIFICATION_SOURCE, text_to_show))
            .to eq({ color:    '#439FE0',
                     fallback: expected_title,
                     title:    expected_title,
                     footer:   "SHF: #{NOTIFICATION_SOURCE}",
                     ts:       test_time.to_i })
      end # Timecop
    end

    it 'the source of the notification is put into the footer' do

      test_time = DateTime.civil_from_format(:utc, 2018)
      Timecop.freeze(test_time) do

        notification_source = 'some source'
        expected_title      = " #{test_time.strftime("%F %T UTC")}"

        expect(SHFNotifySlack.make_details(notification_source))
            .to eq({ color:    '#439FE0',
                     fallback: expected_title,
                     title:    expected_title,
                     footer:   "SHF: #{notification_source}",
                     ts:       test_time.to_i })
      end # Timecop
    end

    it 'can set the color' do
      test_time = DateTime.civil_from_format(:utc, 2018)
      Timecop.freeze(test_time) do

        color          = '#121212'
        expected_title = " #{test_time.strftime("%F %T UTC")}"

        expect(SHFNotifySlack.make_details(NOTIFICATION_SOURCE, color: color))
            .to eq({ color:    color,
                     fallback: expected_title,
                     title:    expected_title,
                     footer:   "SHF: #{NOTIFICATION_SOURCE}",
                     ts:       test_time.to_i })
      end # Timecop
    end

  end


  it 'timestamped_text appends a timestamp to the text' do

    test_time = DateTime.civil_from_format(:utc, 2018)

    Timecop.freeze(test_time) do
      expect(SHFNotifySlack.timestamped_text('text')).to eq("text #{test_time.strftime("%F %T UTC")}")
    end
  end

  it '.footer_text has "SHF:" at the start' do
    expect(SHFNotifySlack.footer_text('blorf')).to eq('SHF: blorf')
  end
end
