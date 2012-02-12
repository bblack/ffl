$.widget('ffl.ticker', {
  options: {
    text: "Fetching data...",
    speed: 10,
    dataUrl: null,
    dataToHtml: function(data) {}
  },

  _create: function() {
    this.span1 = $("<span class='tickerspan' />");
    this.span1.text(this.options.text);
    this.element.empty();
    this.element.append(this.span1);
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
          this.span1.html(this.options.dataToHtml(data));
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