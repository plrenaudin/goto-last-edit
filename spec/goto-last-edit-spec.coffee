GotoLastEdit = require '../lib/goto-last-edit'

describe "GotoLastEdit", ->
  [workspaceElement, promise, thisPackage] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    atom.project.setPaths([__dirname])
    spyOn(atom.workspace, 'open').andCallThrough()
    promise = atom.packages.activatePackage('goto-last-edit').then ({mainModule}) ->
      thisPackage = mainModule
      atom.workspace.open('../lib/goto-last-edit.coffee')
      atom.workspace.open('../keymaps/goto-last-edit.cson')

  describe "when the goto-last-edit:run event is triggered", ->
    it "goes to the last edit", ->
      waitsForPromise ->
        promise

      runs ->
        activeEditor = atom.workspace.getActiveTextEditor()
        expect(activeEditor.getPath()).toContain 'goto-last-edit.cson'
        # Change cursor position
        activeEditor.moveDown(2)
        activeEditor.moveRight(2)

        # Write something
        activeEditor.insertText('Edit')
        window.advanceClock(1000)
        expect(activeEditor.getCursorBufferPosition()).toEqual [2, 6]
        expect(thisPackage.lastEditPosition.position).toEqual [2, 6]

        # Change editor
        atom.workspace.getActivePane().activatePreviousItem()
        activeEditor = atom.workspace.getActiveTextEditor()
        expect(activeEditor.getPath()).toContain 'goto-last-edit.coffee'
        expect(activeEditor.getCursorBufferPosition()).toEqual [0, 0]

        # Run the goto last edit command
        atom.commands.dispatch workspaceElement, 'goto-last-edit:run'
        options = {
          initialLine: 2,
          initialColumn: 6,
          activatePane: true,
          searchAllPanes: true
        }
        expect(atom.workspace.open.callCount).toBe 3
        spyCall = atom.workspace.open.mostRecentCall
        expect(spyCall.args[0]).toContain('goto-last-edit.cson')
        expect(spyCall.args[1]).toEqual options
