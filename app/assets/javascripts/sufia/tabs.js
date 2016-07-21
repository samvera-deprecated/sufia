// This code is to implement the tabs on the home page
Blacklight.onLoad(function () {
  // When we visit a link to a tab, open that tab.
  var url = document.location.toString();
  if (url.match('#')) {
    $('.nav-tabs a[href="#' + url.split('#')[1] + '"]').tab('show');
  }
  
  // Change the url when a tab is clicked.
  $('a[data-toggle="tab"]').on('click', function(e) {
    history.pushState(null, null, $(this).attr('href'));
  });

  // navigate to a tab when the history changes
  window.addEventListener("popstate", function(e) {
    var activeTab = $('[href="' + location.hash + '"]');
    if (activeTab.length) {
      activeTab.tab('show');
    } else {
      var firstTab = $('.nav-tabs a:first');
      // select the first tab if it has an id and is expected to be selected
      if (firstTab.id[0] != ""){
        $(firstTab).tab('show');
      }
    }
  });
});
