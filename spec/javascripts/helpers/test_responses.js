var TestResponses = {
  single_use_link: {
    success: {
      status: 200,
      responseText: "http://test.host/single_use_linkabc123"
    }
  },
  form_add_remove_table_rows: {
    api_add_success: {
      child: {
        id: "child1234",
        path: "/concerns/generic_work/child1234",
        title: ["child"]
      },
      parent: {
        id: "parent5678",
        path: "/concerns/generic_work/parent5678",
        title: ["parent"]
      }
    },
    api_remove_success:{},
    api_error: {
      responseText: "Error"
    },
  }
}
