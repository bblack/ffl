// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function fieldValueChanged(field) {
  field.style.backgroundColor = 'pink';
}

$(document).ready(function(){
  $("#navbar-league-li").mouseenter(function(){
    $("#user-team-selector").show();
  });

  $("#navbar-league-li").mouseleave(function(event){
    $("#user-team-selector").hide();
  });
});

$(function (){
  var cache = {}, lastXhr;
  $("[player_finder]").autocomplete({
    minLength: 3,
    select: function(event, ui){
      $("#player_id").val(ui.item.id.toString());
    },
    source: function(request, response) {
      var term = request.term;
      if (term in cache) {
        response(cache[term]);
        return;
      }
      
      lastXhr = $.getJSON("/players.json", {'last_name': term}, function(data, status, xhr){
        ret = [];
        for (var i = 0; i < data.length; i++)
        {
          var p = data[i].player;
          var showtext = p.first_name + " " + p.last_name + " (" + p.position + ", " + p.nfl_team + ")";
          ret.push({
            label: showtext,
            value: showtext,
            id: data[i].player.id
          });
        }
        cache[term] = ret;
        if (xhr === lastXhr) {
          response(ret);
        }
      });
    }
  });
});