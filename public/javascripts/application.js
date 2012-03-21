// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function fieldValueChanged(field) {
  field.style.backgroundColor = 'pink';
}

$(document).ready(function(){
  $("#navbar-league-li").mouseenter(function(){
    $("#user-team-selector").css('display', 'table');
  });

  $("#navbar-league-li").mouseleave(function(event){
    $("#user-team-selector").css('display', 'none');
  });
});