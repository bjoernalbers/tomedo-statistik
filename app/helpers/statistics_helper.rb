module StatisticsHelper
  def modal(title, &block)
    id = 'modal_' + SecureRandom.hex(10)
    render 'modal', title: title, id: id, &block
  end
end
