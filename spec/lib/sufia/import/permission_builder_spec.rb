require 'spec_helper'

describe Sufia::Import::PermissionBuilder do
  let(:user) { create(:user) }
  let(:builder) { described_class.new }
  subject { object.permissions.map(&:to_hash) }

  let(:permissions) do
    [
      { id: "abc12333-07b1-43ab-b11d-1bc0534d874c",
        agent: "http://projecthydra.org/ns/auth/person##{user.user_key}",
        mode: "http://www.w3.org/ns/auth/acl#Write",
        access_to: "44558d49x" },
      { id: "b5911dfd-07b1-43ab-b11d-1bc0534d874c",
        agent: "http://projecthydra.org/ns/auth/person#cam156@psu.edu",
        mode: "http://www.w3.org/ns/auth/acl#Write",
        access_to: "44558d49x" },
      { id: "db8e6b05-3fe1-4d3f-9905-5232ba49f8f5",
        agent: "http://projecthydra.org/ns/auth/person#other@psu.edu",
        mode: "http://www.w3.org/ns/auth/acl#Read",
        access_to: "44558d49x" },
      { id: "d49df87b-bda6-4fdd-8f14-3ff421339a1b",
        agent: "http://projecthydra.org/ns/auth/group#umg/group.psu",
        mode: "http://www.w3.org/ns/auth/acl#Read",
        access_to: "44558d49x" }
    ]
  end

  before do
    builder.build(object, permissions)
  end
  context "when adding permissions to the work" do
    let(:object) { create(:generic_work, user: user) }

    it do
      is_expected.to contain_exactly({ name: "cam156@psu.edu", type: "person", access: "edit" },
                                     { name: "other@psu.edu", type: "person", access: "read" },
                                     { name: user.user_key, type: "person", access: "edit" },
                                     name: "umg/group.psu", type: "group", access: "read")
    end
  end
  context "when adding permissions to the file set" do
    let(:object) { create(:file_set, user: user) }

    it do
      is_expected.to contain_exactly({ name: "cam156@psu.edu", type: "person", access: "edit" },
                                     { name: "other@psu.edu", type: "person", access: "read" },
                                     { name: user.user_key, type: "person", access: "edit" },
                                     name: "umg/group.psu", type: "group", access: "read")
    end
  end
end
