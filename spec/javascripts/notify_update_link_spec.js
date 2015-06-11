describe("notify update link", function() {
    it("clicks the link", function(){
        setFixtures('<div id="notify_update_link"></div>')
        spyEvent = spyOnEvent('#notify_update_link', 'click');
        notify_update_link();
        expect(spyEvent).toHaveBeenTriggered();
    });
});
