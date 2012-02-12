$.widget('ffl.ticker', {
  options: {
    text: "Fetching data...",
    speed: 10,
    dataUrl: null,
    dataToHtml: function(data) {}
  },

  _create: function() {
    this.element.empty();
    
    img_back = $("<img src='/images/ticker-back.png' style='position:absolute;' />");
    img_back.css('top', 0);
    img_back.css('left', 0);
    img_back.css('height', this.element.innerHeight());
    img_back.css('width', '100%');
    this.element.append(img_back);
    
    this.span1 = $("<span class='tickerspan' />");
    this.element.append(this.span1);
    
    img_right = $("<img src='/images/ticker-right.png' style='position:absolute;' />");
    img_right.css('top', 0);
    img_right.css('right', 0);
    img_right.css('height', this.element.innerHeight());
    this.element.append(img_right);
    
    img_left = $("<img src='/images/ticker-left.png' style='position:absolute;' />");
    img_left.css('top', 0);
    img_left.css('left', 0);
    img_left.css('height', this.element.innerHeight());
    this.element.append(img_left);
    
    this._resetPosition();
    this._tick();
  },
  
  _resetPosition: function() {
    this.span1.css('left', this.element.width().toString() + 'px');
    if (this.options.dataUrl)
    {
      $.ajax({
        url: this.options.dataUrl,
        success: $.proxy(function(data){
          var tickerhtml = '';
          try { tickerhtml = this.options.dataToHtml(data) }
          catch (e) { tickerhtml = '<span style="color:#f60;">Error parsing data!</span>' }
          this.span1.html(tickerhtml);
        }, this)
      });
    }
  },
  
  _tick: function() {
    var leftPos = parseInt(this.span1.css('left').replace('px',''));
  
    if (isNaN(leftPos) || leftPos < -this.span1.width()) {
      this._resetPosition();
    }
    else
    {
      this.span1.css('left', leftPos - 2);
    }
    setTimeout($.proxy(this._tick, this), this.options.speed);
  }
});