module ExportJsonHelper
  def generic_file_json(options = {})
    "{
      \"id\": \"#{options.fetch(:id, '44558d49x')}\",
      \"label\": \"#{options.fetch(:label, '15040187724_9e2f2d7c21_z.jpg')}\",
      \"depositor\": \"cam156@psu.edu\",
      \"arkivo_checksum\": \"arkivo checksum\",
      \"relative_path\": \"relative path\",
      \"import_url\": \"import url\",
      \"resource_type\": [\"resource type\"],
      \"title\": #{options.fetch(:title, '["My Awesone File"]')},
      \"creator\": [ \"cam156@psu.edu\" ],
      \"contributor\": [\"contributor1\", \"contribnutor2\"],
      \"description\": [\"description of the file\"],
      \"tag\": [\"tag1\", \"tag2\"],
      \"rights\": [\"#{options.fetch(:rights, 'Attribution 3.0')}\"],
      \"publisher\": [\"publisher joe\"],
      \"date_created\": [\"a long time ago\"],
      \"date_uploaded\": \"#{options.fetch(:date_uploaded, '2016-09-28T20:00:14.243+00:00')}\",
      \"date_modified\": \"#{options.fetch(:date_modified, '2016-09-28T17:32:46.610-04:00')}\",
      \"subject\": [\"subject 1\", \"subject 2\"],
      \"language\": [\"WA Language WA\"],
      \"identifier\": [\"You ID ME\"],
      \"based_near\": [\"Kalamazoo\"],
      \"related_url\": [\"abc123.org\"],
      \"bibliographic_citation\": [\"cite me\"],
      \"source\": [\"source of me\"],
      \"batch_id\": \"qn59q409q\",
      \"visibility\": \"restricted\",
      \"versions\": #{versions_json(options)},
      \"permissions\": #{permissions_json(options)}
    }"
  end

  def permissions_json(_options = {})
    "[
        {
          \"id\": \"b5911dfd-07b1-43ab-b11d-1bc0534d874c\",
          \"agent\": \"http://projecthydra.org/ns/auth/person#cam156@psu.edu\",
          \"mode\": \"http://www.w3.org/ns/auth/acl#Write\",
          \"access_to\": \"44558d49x\"
        },
        {
          \"id\": \"db8e6b05-3fe1-4d3f-9905-5232ba49f8f5\",
          \"agent\": \"http://projecthydra.org/ns/auth/person#other@psu.edu\",
          \"mode\": \"http://www.w3.org/ns/auth/acl#Read\",
          \"access_to\": \"44558d49x\"
        }
      ]"
  end

  def versions_json(_options = {})
    "[
        {
          \"uri\": \"http://127.0.0.1:8983/fedora/rest/dev/44/55/8d/49/44558d49x/content/fcr:versions/version1\",
          \"created\": \"2016-09-28T20:00:14.658Z\",
          \"label\": \"version1\"
        },
        {
          \"uri\": \"http://127.0.0.1:8983/fedora/rest/dev/44/55/8d/49/44558d49x/content/fcr:versions/version2\",
          \"created\": \"2016-09-29T15:58:00.639Z\",
          \"label\": \"version2\"
        }
      ]"
  end

  def collection_json(options = {})
    "{
      \"id\": \"#{options.fetch(:id, '2v23vt57t')}\",
      \"title\": \"#{options.fetch(:title, 'Fantasy')}\",
      \"depositor\": \"archivist@example.com\",
      \"description\": \"Magic and power\",
      \"creator\": [
        \"Arthur\"
      ],
      \"members\": #{options.fetch(:member_ids, [])},
      \"permissions\": [
        {
          \"id\": \"e78502f4-9e46-47b1-9d43-835004228573\",
          \"agent\": \"http://projecthydra.org/ns/auth/group#public\",
          \"mode\": \"http://www.w3.org/ns/auth/acl#Read\",
          \"access_to\": \"2v23vt57t\"
        },
        {
          \"id\": \"2a9205fa-ad70-4888-9441-39bfba6fc95e\",
          \"agent\": \"http://projecthydra.org/ns/auth/person#archivist@example.com\",
          \"mode\": \"http://www.w3.org/ns/auth/acl#Write\",
          \"access_to\": \"2v23vt57t\"
        }
      ]
    }"
  end

  RSpec.configure do |config|
    config.include ExportJsonHelper
  end
end
