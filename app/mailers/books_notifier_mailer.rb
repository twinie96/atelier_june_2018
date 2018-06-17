class BooksNotifierMailer < ApplicationMailer
  default from: 'warsztaty@infakt.pl'
  layout 'mailer'

  def send_if_taken(book, user)
    @book = book
    @user = user

    mail(to: user.email, subject: "Book taken")
  end

end
