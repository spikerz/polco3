class BillsController < InheritedResources::Base
  load_and_authorize_resource
  has_scope :page, :default => 1

  def show
    @bill = Bill.find(params[:id])
    #@bill_text = @bill.get_bill_text
    # comment fields
    @comment = Comment.new
    @author = current_user.nil? ? "" : current_user.name
    @email = current_user.nil? ? "" : current_user.email
    # # #
    show!
  end

end
