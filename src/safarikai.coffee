((doc, window) ->
  mouseEventHandler = (e) ->
    range = doc.caretRangeFromPoint e.clientX, e.clientY
    if range
      range.expand "word"
      sel = doc.defaultView.getSelection()
      safari.self.tab.dispatchMessage "testMessage", range.toString()
      #sel.removeAllRanges()
      #sel.addRange range

  doc.onmousemove = doc.onmouseover = doc.onmouseout = mouseEventHandler

  messageEventHandler = (e) ->
    messageName = e.name
    messageData = e.message
    # TODO: filter and dispatch messages

  safari.self.addEventListener "message", messageEventHandler, false
)(document, window)
