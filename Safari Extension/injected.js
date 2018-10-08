class Client {
  constructor(doc, window) {
    this.doc = doc;
    this.window = window;
    this.clientX         = 0;
    this.clientY         = 0;
    this.popupTagId      = "safarikai-popup";
    this.enabled         = true;
    this.mouseDown       = false;
    this.highlighted     = false;
    this.highlightText   = true;
    this.showRomaji      = true;
    this.showTranslation = true;
    this.rangeOffset   = 0;

    this.doc.onmousemove = e => {
      if (!this.enabled || !!this.mouseDown) {
        this.hidePopup();
      } else {
        this.createRange(e);
        if ((this.selectionText != null ? this.selectionText.length : undefined) > 0) {
          safari.extension.dispatchMessage("lookupWord", {word: this.selectionText, url: this.window.location.href});
        } else {
          this.clearHighlight();
          this.hidePopup();
        }
      }
      return true;
    };

    this.doc.onmouseout  = e => this.hidePopup();
    this.doc.onmousedown = e => {
      if (e.button === 0) {
        this.mouseDown = true;
        this.clearHighlight();
      }
      return true;
    };
    this.doc.onmouseup   = e => {
      if (e.button === 0) {
        this.mouseDown = false;
      }
      return true;
    };

    safari.self.addEventListener("message", e => {
      const messageData = e.message;

      switch (e.name) {
        case "showResult": return this.showResult(messageData.word, messageData.url, messageData.result);
        case "status": return this.updateStatus(messageData);
      }
    });

    // Ask status on load
    safari.extension.dispatchMessage("queryStatus");
  }

  createRange(e) {
    this.clientX = e.clientX;
    this.clientY = e.clientY;
    const ele = this.doc.elementFromPoint(this.clientX, this.clientY);
    this.range = null;
    if (["TEXTAREA", "INPUT"].includes(ele.tagName)) {
      return this.selectionText = "";
    } else if (ele.tagName === "IMG") {
      return this.selectionText = ele.alt.trim();
    } else {
      const range = this.doc.caretRangeFromPoint(this.clientX, this.clientY);
      if (!range) { return; }

      let container = range.startContainer;
      let offset = range.startOffset;

      if (offset === (container.data != null ? container.data.length : undefined)) {
        if (this.isInlineNode(e.target) && (container.parentNode.innerText !== e.target.innerText)) {
          container = e.target.firstChild;
          offset = 0;
        }
      }

      range.setStart(container, offset);
      range.setEnd(container, Math.min(container.data != null ? container.data.length : undefined, offset + 20));

      const text = range.toString();
      if (text !== this.selectionText) {
        this.range = range;
        this.rangeOffset = offset;
        return this.selectionText = text;
      }
    }
  }

  highlight(word) {
    if (!this.highlightText || !this.range) { return; }
    if (this.mouseDown) { return; }
    const sel = this.doc.defaultView.getSelection();
    if (!this.highlighted && (sel.toString().length > 0)) { return; } // user selection
    sel.removeAllRanges();
    if (this.range) {
      const container = this.range.startContainer;
      this.range.setEnd(container, Math.min(container.data != null ? container.data.length : undefined, this.rangeOffset + word.length));
      sel.addRange(this.range);
    }
    return this.highlighted = true;
  }

  clearHighlight() {
    if (!this.highlightText) { return; }
    if (this.highlighted) {
      const sel = this.doc.defaultView.getSelection();
      sel.removeAllRanges();
      return this.highlighted = false;
    }
  }

  getPopup() { return this.doc.getElementById(this.popupTagId); }

  injectPopup() {
    if (this.getPopup()) { return; }

    const popup = this.doc.createElement("div");
    popup.id = "safarikai-popup";
    return this.doc.body.appendChild(popup);
  }

  hidePopup() { return __guard__(this.getPopup(), x => x.style.display = "none"); }

  decorateRow(row) {
    const kanji = row.kanji !== row.kana ? row.kanji : "";
    return `\
<li>
  <div class='kana'>${ row.kana }</div>
  ${ kanji.length > 0 ? `<div class='kanji'>${kanji}</div>` : "" }
  ${ this.showRomaji || this.showTranslation ? "<div class='translation'>" : "" }
    ${ this.showRomaji ? `<div class='romaji'>[${row.romaji}]</div>` : "" }
    ${ this.showTranslation ? `${row.translation}` : "" }
  ${ this.showRomaji || this.showTranslation ? "</div>" : "" }
</li>\
`;
  }

  showResult(word, url, result) {
    if (this.window.location.href !== url) { return; }

    this.injectPopup();
    const popup = this.getPopup();
    popup.style.display = "block";
    if (result.length === 0) {
      this.clearHighlight();
      return this.hidePopup();
    } else {
      this.highlight(word);
      const htmlRows = (Array.from(result).map((row) => this.decorateRow(row)));
      popup.innerHTML = `<ul class='results'>${ htmlRows.join('') }</ul>`;
      popup.style.maxWidth = this.window.innerWidth < 400 ? "80%" : "500px";

      let left = this.clientX + this.window.scrollX;
      const overflowX = ((this.clientX + popup.offsetWidth) - this.window.innerWidth) + 10;
      if (overflowX > 0) { left -= overflowX; }
      popup.style.left = left + "px";

      const margin = 30;
      let top = this.clientY + this.window.scrollY + margin;
      if (this.clientY > (this.window.innerHeight / 2)) { top = (this.clientY + this.window.scrollY) - popup.offsetHeight - margin; }
      return popup.style.top = top + "px";
    }
  }

  updateStatus(status) {
    this.enabled         = status.enabled;
    this.highlightText   = status.highlightText;
    this.showRomaji      = status.showRomaji;
    this.showTranslation = status.showTranslation;
    if (!this.enabled) { return this.hidePopup(); }
  }

  isInlineNode(node) {
    if (node.nodeName === "#text") { return true; }
    const display = this.doc.defaultView.getComputedStyle(node, null).getPropertyValue("display");
    return (display === "inline") || (display === "inline-block");
  }
}

const client = new Client(document, window);

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
