$ document .ready ->
  dialogs = document.query-selector-all 'dialog'
  for dialog in dialogs
    dialog-polyfill.register-dialog dialog

  $ 'form' .submit (event) ->
    event.prevent-default!

    is-valid = this.check-validity!
    return false unless is-valid

    $ 'dialog.confirm' .get 0 .show-modal!
    return false

  $ 'dialog' .each ->
    $ this .find '.close' .click ~> this.close!

  $ 'dialog.confirm button.submit' .click (event) ->
    $ 'dialog.confirm' .get 0 .close!
    $ 'dialog.result' .get 0 .show-modal!

    $ 'dialog.result .mdl-spinner' .add-class 'is-active'

    $.ajax do
      type: 'POST'
      url: 'https://api.hakatashi.com/sos/send'
      data: $ 'form' .serialize!
      success: (e) ->
        console.log e
      error: (e) ->
        console.log e
