{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null
  lastEditPosition: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'goto-last-edit:run': => @run()

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      editor.onDidStopChanging =>
        if editor.buffer.previousModifiedStatus or editor.isModified()
          @lastEditPosition = {
            pane: atom.workspace.getActivePane(),
            editor: editor,
            position: editor.cursors[0]?.getBufferPosition()
          }

  run: ->
    if @lastEditPosition
      if @lastEditPosition.editor.buffer.file?.path
        options = {
          initialLine: @lastEditPosition.position.row,
          initialColumn: @lastEditPosition.position.column,
          activatePane: true,
          searchAllPanes: true
        }
        atom.workspace.open(@lastEditPosition.editor.buffer.file?.path, options)
      else
        if @lastEditPosition.editor not in atom.workspace.getTextEditors()
          return
        if @lastEditPosition.pane isnt atom.workspace.getActivePane()
          @lastEditPosition.pane.activate()
        if @lastEditPosition.editor isnt atom.workspace.getActiveTextEditor()
          atom.workspace.getActivePane().activateItem(@lastEditPosition.editor)
        atom.workspace.getActiveTextEditor().setCursorBufferPosition(
          @lastEditPosition.position,
          autoscroll: false
        )
        atom.workspace.getActiveTextEditor().scrollToCursorPosition(center: true)

  deactivate: ->
    @subscriptions.dispose()
