{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null
  lastEditPosition: null

  activate: (state) ->
    console.log "activate goto last"
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'goto-last-edit:run': => @run()

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      editor.onDidStopChanging (event) =>
        console.log atom.workspace.getActivePane()
        @lastEditPosition = {
          pane: atom.workspace.getActivePane(),
          editor: editor,
          position: editor.cursors[0]?.getBufferPosition()
        }

  run: ->
    console.log 'GotoLastEdit was runned!', @lastEditPosition
    if @lastEditPosition
      if @lastEditPosition.pane not in atom.workspace.getPanes()
        console.log 'no more pane : create a new one'
        atom.workspace.open(@lastEditPosition.editor.buffer.file?.path)
        return
      if @lastEditPosition.pane isnt atom.workspace.getActivePane()
        console.log 'swith to the same pane as the one of the last position'
        @lastEditPosition.pane.activate()
      if @lastEditPosition.editor isnt atom.workspace.getActiveTextEditor()
        console.log 'activate text editor??..'
        debugger
        atom.workspace.getActivePane().activateItem(@lastEditPosition.editor)
        if @lastEditPosition.editor isnt atom.workspace.getActiveTextEditor()
          console.log 'still not the editor we want!'
      atom.workspace.getActiveTextEditor().setCursorBufferPosition(
        @lastEditPosition.position,
        autoscroll:false
      )
      atom.workspace.getActiveTextEditor().scrollToCursorPosition(center:true)

  deactivate: ->
    @subscriptions.dispose()
