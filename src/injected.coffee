class Client
  constructor: (@doc, @window) ->
    @clientX = 0
    @clientY = 0
    @popupTagId = "safarikai-popup"
    @enabled    = false

    @doc.onmousemove = (e) =>
      unless @enabled
        @hidePopup()
        return

      @clientX = e.clientX
      @clientY = e.clientY
      range = @doc.caretRangeFromPoint e.clientX, e.clientY
      if range
        range.expand "word"
        sel = @doc.defaultView.getSelection()
        word = range.toString().trim()
        safari.self.tab.dispatchMessage "lookupWord", word: word, url: @window.location.href
        #sel.removeAllRanges()
        #sel.addRange range

    @doc.onmouseout = (e) => @hidePopup()

    safari.self.addEventListener "message", (e) =>
      messageData = e.message

      switch e.name
        when "showResult" then @showResult messageData.word, messageData.url, messageData.result
        when "status" then @updateStatus messageData

    # Ask status on load
    safari.self.tab.dispatchMessage "queryStatus"

  getPopup: -> @doc.getElementById @popupTagId

  injectPopup: ->
    return if @getPopup()

    popup = @doc.createElement "div"
    popup.id = "safarikai-popup"
    @doc.body.appendChild popup

  hidePopup: -> @getPopup().style.display = "none"

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
      @hidePopup()
    else
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
    @enabled = status.enabled
    @hidePopup() unless @enabled

client = new Client document, window
