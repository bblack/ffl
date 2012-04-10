class TransactionsController < ApplicationController

  def index
    @transactions = Transaction.where(:user_id => @current_user.id, :completed_on => nil)
  end

  def create
    new_transaction = Transaction.create(:user_id => @current_user.id)
    add_flash(:notice, false, "Transaction ##{new_transaction.id} is created and ready for you to work on.")
    redirect_to transaction_path(new_transaction.id)
  end

  def show
    @transaction = Transaction.find params[:id]
  end

  # Non-crud below

  def complete
    @transaction = Transaction.find params[:id]
    begin
      @transaction.complete!
      add_flash(:notice, false, "Transaction ##{@transaction.id} is completed! All its moves have been made.")
    rescue ActiveRecord::RecordInvalid => e
      add_flash(:error, false, e.to_s)
    end
    redirect_to :back
  end
end