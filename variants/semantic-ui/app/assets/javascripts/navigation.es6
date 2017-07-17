ready(() => {
  // hide items with no sub-items
  // this usually happens when the user doesn't have permission to anything in the group
  $('.sidebar > .item:has(.menu)').filter((ix, e) => {
    return $(e).find('.menu').children().length == 0
  }).hide()
})
