describe 'form add remove table rows', ->
  add_btn = null
  remove_btn = null
  edit_btn = null
  add_input = null
  table = null
  row = null
  message = null

  test_fixtures = TestFixtures
  test_responses = TestResponses
  deferred = null

  beforeEach ->
    setFixtures test_fixtures.form_add_remove_table_rows.table_html
    add_btn = $('.btn-add-row:first')
    row = $(add_btn).parents("tr:first")
    remove_btn = $(row).find('.btn-remove-row:first')
    edit_btn = $(row).find('.edit:first')
    add_input = $(row).find('.new-form-control:first')
    table = $(row).parents("table:first")
    message = $(row).find(".message:first")
    jasmine.Ajax.install()

    deferred = new jQuery.Deferred()
    spyOn($,'ajax').and.returnValue(deferred)

  afterEach ->
    jasmine.Ajax.uninstall()

  describe 'when adding/removing a row', ->
    # the new-row is properly rendered
    it 'only displays one new row with an add button', ->
      expect($(remove_btn).hasClass("hidden")).toBeTruthy()
      expect($(row).find(".edit").hasClass("hidden")).toBeTruthy()
      expect($(add_btn).hasClass("hidden")).toBeFalsy()

    # call ajax to add a row
    it 'clicks add with a valid id', ->
      add_input.val(test_fixtures.form_add_remove_table_rows.parent_id)
      add_btn.click()
      deferred.resolve(test_responses.form_add_remove_table_rows.api_add_success)
      expect($(message).hasClass("hidden")).toBeTruthy()
      expect($(table).find("tbody tr").length).toEqual(2)

    # call ajax to add an invalid row
    it 'clicks add with an invalid id', ->
      add_input.val('invalid')
      add_btn.click()
      deferred.reject(test_responses.form_add_remove_table_rows.api_error)
      expect($(message).hasClass("hidden")).toBeFalsy()
      expect($(table).find("tbody tr").length).toEqual(1)

    # don't call ajax with an empty row
    it 'clicks add without an id', ->
      expect($(message).hasClass("hidden")).toBeTruthy()
      add_btn.click()
      expect($(message).hasClass("hidden")).toBeFalsy()
      expect($(message).text()).toContain("ID cannot be empty")
      expect($(table).find("tbody tr").length).toEqual(1)

    # clicking delete removes an existing row
    it 'clicks remove to remove a work', ->
      add_input.val(test_fixtures.form_add_remove_table_rows.parent_id)
      add_btn.click()
      deferred.resolve(test_responses.form_add_remove_table_rows.api_add_success)
      expect($(table).find("tbody tr").length).toEqual(2)
      parent_row = $(table).find("tbody tr:first")
      parent_delete = $(parent_row).find(".btn-remove-row:first")
      $(parent_delete).click()
      deferred.resolve(test_responses.form_add_remove_table_rows.api_remove_success)
      expect($(table).find("tbody tr").length).toEqual(1)
