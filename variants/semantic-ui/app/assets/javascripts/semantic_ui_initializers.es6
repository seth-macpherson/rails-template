ready(() => {
  $('select.dropdown').dropdown({
    fullTextSearch: 'exact',
    forceSelection: false
  })

  $('.dropdown').dropdown()

  // Fancy popups
  $('.popup, [title]').popup()

  // Selecting tabs
  $('.menu .item[data-tab]').tab({
    // when changing tabs, update the hash in the URL
    onLoad: (p) => window.location.hash = p
  })

  // If a tab name exists in the location hash, select the tab on load
  let tabName = window.location.hash.substring(1)
  if (tabName) {
    $('.menu .item[data-tab]').tab('change tab', tabName)
  }

  // Make messages dismissable
  $('.message .close').on('click', (e) => {
    $(e.target).closest('.message').transition('fade')
  })

  // Sidebar toggler
  $('.ui.sidebar').sidebar('attach events', '.launch')
})
