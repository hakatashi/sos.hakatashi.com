$ document .ready ->
  $ 'form' .on 'submit' (event) ->
    is-valid = this.check-validity!
    return false unless is-valid
