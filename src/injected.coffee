class Client
  constructor: (@doc, @window) ->
    @clientX       = 0
    @clientY       = 0
    @popupTagId    = "safarikai-popup"
    @enabled       = false
    @mouseDown     = false
    @highlighted   = false
    @highlightText = true

    @doc.onmousemove = (e) =>
      unless @enabled and not @mouseDown
        @hidePopup()
        return

      @clientX = e.clientX
      @clientY = e.clientY
      @createRange e.clientX, e.clientY
      safari.self.tab.dispatchMessage "lookupWord", word: @selectionText, url: @window.location.href if @selectionText?.length > 0

    @doc.onmouseout  = (e) => @hidePopup()
    @doc.onmousedown = (e) =>
      return if e.button isnt 0
      @mouseDown = true
      @clearHighlight()
    @doc.onmouseup   = (e) =>
      return if e.button isnt 0
      @mouseDown = false

    safari.self.addEventListener "message", (e) =>
      messageData = e.message

      switch e.name
        when "showResult" then @showResult messageData.word, messageData.url, messageData.result
        when "status" then @updateStatus messageData

    # Ask status on load
    safari.self.tab.dispatchMessage "queryStatus"

  createRange: (x, y) ->
    ele = @doc.elementFromPoint(x, y)
    if ele.tagName is "IMG"
      @selectionText = ele.alt.trim()
    else
      range = @doc.caretRangeFromPoint x, y
      if range
        range.expand "word"
        text = range.toString()
        if text.length > 0 and text isnt @selectionText
          @range = range
          @selectionText = text

  highlight: ->
    return unless @highlightText and @range
    return if @mouseDown
    sel = @doc.defaultView.getSelection()
    if not @highlighted and sel.toString().length > 0
      return
    sel.removeAllRanges()
    sel.addRange @range
    @highlighted = true

  clearHighlight: ->
    return unless @highlightText
    if @highlighted
      sel = @doc.defaultView.getSelection()
      sel.removeAllRanges()
      @highlighted = false

  getPopup: -> @doc.getElementById @popupTagId

  injectPopup: ->
    return if @getPopup()

    popup = @doc.createElement "div"
    popup.id = "safarikai-popup"
    @doc.body.appendChild popup

  hidePopup: -> @getPopup()?.style.display = "none"

  decorateRow: (row) ->
    kanji = if row.kanji.length isnt 0 then row.kanji else row.kana
    translation = row.translation.replace /;/g, "; "
    """
    <li>
      <div class='kana'>#{ row.kana }</div>
      <div class='romaji'>#{ row.romaji }</div>
      <div class='kanji'>#{ kanji }</div>
      <div class='translation'>#{ translation }</div>
    </li>
    """

  showResult: (word, url, result) ->
    return if @window.location.href isnt url

    @injectPopup()
    popup = @getPopup()
    popup.style.display = "block"
    if result.length is 0
      @clearHighlight()
      @hidePopup()
    else
      @highlight()
      htmlRows = (@decorateRow row for row in result)
      popup.innerHTML = "<ul>#{ htmlRows.join '' }</ul>"

      margin = 30

      left = @clientX + @window.scrollX
      overflowX = @clientX + popup.offsetWidth - @window.innerWidth + margin
      left -= overflowX if overflowX > 0
      popup.style.left = left + "px"

      top = @clientY + @window.scrollY + margin
      top = @clientY + @window.scrollY - popup.offsetHeight - margin if @clientY > @window.innerHeight / 2
      popup.style.top = top + "px"

  updateStatus: (status) ->
    @enabled       = status.enabled
    @highlightText = status.highlightText is "on"
    @hidePopup() unless @enabled

client = new Client document, window
