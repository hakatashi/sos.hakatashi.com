$ document .ready ->
  dialogs = document.query-selector-all 'dialog'
  for dialog in dialogs
    dialog-polyfill.register-dialog dialog

  $ 'form' .on 'submit' (event) ->
    event.prevent-default!

    is-valid = this.check-validity!
    return false unless is-valid

    $ 'dialog.confirm' .get 0 .show-modal!
    return false

  $ 'dialog' .each ->
    $ this .find '.close' .click ~> this.close!
