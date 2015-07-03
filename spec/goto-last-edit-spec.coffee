GotoLastEdit = require '../lib/goto-last-edit'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "GotoLastEdit", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('goto-last-edit')

  describe "when the goto-last-edit:run event is triggered", ->
    it "hides and shows the modal panel", ->
      atom.commands.dispatch workspaceElement, 'goto-last-edit:run'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.goto-last-edit')).toExist()
