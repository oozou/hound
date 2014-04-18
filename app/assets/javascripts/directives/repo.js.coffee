App.directive 'repo', ->
  scope:
    repo: '='
  templateUrl: '/templates/repo'

  link: (scope) ->
    activate = (repo) ->
      activate = repo.$activate()
      activate
        .then(-> repo.processing = false)
        .catch(-> alert('Your repo failed to activate.'))

    deactivate = (repo) ->
      deactivate = repo.$deactivate()
      deactivate
        .then(-> repo.processing = false)
        .catch(-> alert('Your repo failed to deactivate.'))

    scope.toggle = (repo) ->
      repo.processing = true
      if repo.active
        deactivate(repo)
      else
        activate(repo)
