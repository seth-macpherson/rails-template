ready(() => {
  $('textarea[data-cmlang]').each((ix, el) => {
    var $el = $(el),
        lang = $el.data('cmlang')
    var editor = CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      insertSoftTab: true,
      theme: 'default',
      mode: lang
    })
    $el.data('editor', editor)
  })
})
