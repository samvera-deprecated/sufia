
describe("toggle icon", function() {
    it("toggles the caret", function(){
        setFixtures('<div id="icon" class="caret"></div>')
        toggle_icon($("#icon"));
        expect($("#icon")).toHaveClass("caret up")
        toggle_icon($("#icon"));
        expect($("#icon")).not.toHaveClass("caret up")
        expect($("#icon")).toHaveClass("caret")
    });
});