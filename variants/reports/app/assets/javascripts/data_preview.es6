ready(() => {
  $('body.reports a.preview.button').on('click', (e) => {
    e.preventDefault()

    var $el = $(e.target),
        url = $el.attr('href'),
        $query = $('#report_query'),
        editor = $query.data('editor'),
        query = !!editor ? editor.getValue() : $query.val(),
        $preview = $('#preview')

    $.post({
      url: url,
      dataType: 'html',
      data: { query: query },
      success: (html) => {
        $preview.html(html)
      },
      error: (xhr, status, error) => {
        $preview.empty()
        $preview.append($('<b>', { text: 'Query failed' }))
        $preview.append($('<pre>', { style: 'color: red', text: xhr.responseText }))
      }
    })
  })
})
