window.TestFixtures = {
  form_add_remove_table_rows: {
    child_id: 'child1234',
    parent_id: 'parent5678'
  }
}

window.TestFixtures.form_add_remove_table_rows["table_html"] = "<table class='table table-striped related-files relationships-api-enabled' data-works-context='parent' data-api-add-url='/api/generic_works/#{TestFixtures.form_add_remove_table_rows.child_id}/add_parent/:id' data-api-remove-url=data-api-url='/api/generic_works/#{TestFixtures.form_add_remove_table_rows.child_id}/remove_parent/:id'> <thead> <tr> <th>Parent Work</th> <th>Actions</th> </tr> </thead> <tbody> <tr class='new-row'> <td> <a href='' class='title hidden'></a> <input class='new-form-control string multi_value optional related_works_ids form-control multi-text-field' name='' value='' aria-labelledby='generic_work_in_works_ids_label' type='text'> <div class='message has-warning hidden'></div> </td> <td> <div class='child-actions'> <a href='' class='edit hidden btn btn-default' target='_blank'>Edit</a> <a class='btn btn-danger btn-remove-row hidden'>Remove</a> <a class='btn btn-primary btn-add-row'>Add</a></div></td></tr></tbody></table>"

