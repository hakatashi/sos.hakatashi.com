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

    $ 'dialog.result .mdl-spinner' .show!add-class 'is-active'
    $content = $ 'dialog.result .mdl-dialog__content'

    $content.find 'h4, p' .remove!

    $.ajax do
      type: 'POST'
      url: 'https://api.hakatashi.com/sos/send'
      data: $ 'form' .serialize!
      data-type: 'json'

      error: (xhr, errorType, error) ->
        $ 'dialog.result .mdl-spinner' .hide!remove-class 'is-active'

        $content.append $ '<h4/>' text: '送信失敗'

        reason = do ->
          try
            data = JSON.parse xhr.response-text
          catch
            return 'エラーが発生しました'

          switch data.error
            | 'Empty body' => 'データが空です'
            | 'SOS request is restricted to 3 times per day' => '一日のSOS送信可能回数を超えました'
            | 'Key mismatch' => '入力されたキーワードが正しくありません'
            | otherwise => 'エラーが発生しました'

        $content.append $ '<p/>' text: reason

      success: (data, status, xhr) ->
        $content.append $ '<h4/>', text: '送信成功'
