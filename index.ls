actions =
  buzzer:
    * 'hakatashi宅のRaspberryPiから大音量でブザー鳴動'
      ...
  ifttt:
    * 'hakatashi宅のRaspberryPiから大音量でブザー鳴動'
    * 'hakatashiのスマホのマナーモードを解除'
    * 'hakatashiのスマホにSMSを送信'
    * 'hakatashiのスマホに通知を送信'
    * 'hakatashiのスマホからAviciiの楽曲をランダムに再生'
    * 'hakatashi宛にTwitterでDMを送信'
    * 'hakatashiのメールアドレス宛にメールを送信'
    * 'hakatashiにSlackでメッセージを送信'
    * 'hakatashiにPushBulletでメッセージを送信'
    * 'hakatashiにYoを送信'

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
    $content = $ 'dialog.result .content-body'
    $content.empty!
    $list = $ 'dialog.result .mdl-list'
    $list.empty!

    form-data = $ 'form' .serialize-array!map (input) ->
      if input.name is 'key'
        input.value .= to-upper-case!
      return input

    $.ajax do
      type: 'POST'
      url: 'https://api.hakatashi.com/sos/send'
      data: form-data
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
        $ 'dialog.result .mdl-spinner' .hide!remove-class 'is-active'

        $content.append $ '<h4/>', text: '送信成功'

        for action, texts of actions
          errored = data.errors[action]?

          $list.append do
            for text in texts
              $ '<li/>' class: 'mdl-list__item' .append do
                $ '<span/>' class: 'mdl-list__item-primary-content' .append [
                  $ '<i/>' do
                    class: 'material-icons mdl-list__item-icon'
                    text: if errored then 'report problem' else 'done'
                  document.create-text-node text
                ]
