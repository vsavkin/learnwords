module ApplicationHelper
  def flash_messages
    messages = flash.map do |message_type, message|
      render(partial: 'partials/flash',
              locals: {message_type: message_type, message: message}) unless message.blank?
    end
#    flash.each{|k,v| flash[v] = nil}
    messages.join('')
  end

  def popup_window(link, title, url)
    link_to_prototype_window link, "uniqwindow",
                             url: url, width: 640, height: 540, className: 'alphacube', recenterAuto: true,
                             draggable: false, resizable: false, title: title,
                             minimizable: false, maximizable: false, effectOptions: {duration: 0.1}
  end
end
