((doc, window) ->
  mouseEventHandler = (e) ->
    range = doc.caretRangeFromPoint e.clientX, e.clientY
    if range
      range.expand "word"
      sel = doc.defaultView.getSelection()
      #sel.removeAllRanges()
      #sel.addRange range

  doc.onmousemove = doc.onmouseover = doc.onmouseout = mouseEventHandler
)(document, window)
