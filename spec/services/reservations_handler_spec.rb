require "rails_helper"

RSpec.describe ReservationsHandler, type: :service do
  let(:user) { User.new }
  let(:book) { Book.new }
  subject { described_class.new(user, book) }

  describe '#reserve' do

    before {
      allow(book).to receive(:can_be_reserved?)
      .with(user).and_return(result)
    }

    context 'without available book' do
      let(:result) { false }
      it {
        expect(subject.reserve).to eq('Book is not available for reservation')
      }
    end

    context 'with available book' do
      let(:result) { true }

      before {
        allow(book).to receive_message_chain(:reservations, :create).with(no_args).with(user: user, status: 'RESERVED').and_return(true)
      }

      it {
        expect(subject.reserve).to be_truthy
      }
    end

  end

  describe '#take' do

    before {
      allow(book).to receive(:can_be_taken?)
      .with(user).and_return(result)
    }

    context 'cannot be taken' do
      let(:result) { false }

      it {
        expect(subject.take).to eq(nil)
      }
    end

    context 'can be taken' do
      let(:result) { true }

      before {
        allow(book).to receive_message_chain(:available_reservation, :present?)
          .with(no_args).with(no_args)
          .and_return(was_taken)
      }

      context 'was taken before' do
        let(:was_taken) { true }

        before {
          allow(book).to receive_message_chain(:available_reservation, :update_attributes).with(no_args).with(status: 'TAKEN').and_return(true)
        }

        it {
          expect(subject.take).to be_truthy
        }
      end

      context 'was not taken before' do
        let(:was_taken) { false }

        before {
          allow(book).to receive_message_chain(:reservations, :create).with(no_args).with(user: user, status: 'TAKEN').and_return(true)
        }

        it {
          expect(subject.take).to be_truthy
        }

      end

    end

  end

end
