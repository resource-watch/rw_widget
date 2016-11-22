require 'acceptance_helper'

module V1
  describe 'Layers', type: :request do
    let!(:settings) {{"marks": {
                      "type_test": "rect",
                      "from": {
                        "data_new": "table"
                    }}}}

    let!(:params) {{ "loggedUser": {"role": "manager", "extraUserData": { "apps": ["gfw","prep"] }, "id": "3242-32442-432"},
                     "widget": { "name": "First test widget", "application": ["gfw"] }}}

    let!(:params_faild) {{ "loggedUser": {"role": "manager", "extraUserData": { "apps": ["gfw","prep"] }, "id": "3242-32442-432"},
                            "widget": { "name": "Widget second one", "application": ["gfw"] }}}

    let!(:widget) {
      Widget.create!(name: 'Widget second one', application: ['gfw'], user_id: '3242-32442-432')
    }

    let!(:widget_id)   { widget.id   }
    let!(:widget_slug) { widget.slug }

    let!(:update_params) {{ "loggedUser": {"role": "admin", "extraUserData": { "apps": ["gfw","prep"] }, "id": "3242-32442-432"},
                            "widget": { "name": "First test one update",
                                        "slug": "updated-first-test-widget", "application": ["gfw"] }
                         }}

    context 'List filters' do
      let!(:disabled_widget) {
        Widget.create!(name: 'Widget second second', slug: 'widget-second-second', status: 3, published: false)
      }

      let!(:enabled_widget) {
        Widget.create!(name: 'AAA Widget one', status: 1, published: true, verified: true, application: ['Gfw', 'wrw'], dataset_id: 'c547146d-de0c-47ff-a406-5125667fd5e6', default: true)
      }

      let!(:enabled_widget_2) {
        Widget.create!(name: 'Widget one two', status: 1, published: true, verified: true, application: ['Gfw', 'test'], dataset_id: 'c547146d-de0c-47ff-a406-5125667fd5e7', template: true)
      }

      let!(:unpublished_widget) {
        Widget.create!(name: 'Widget one unpublished', status: 1, published: false, verified: true)
      }

      let!(:next_widget) {
        Widget.create!(name: 'ZZZ Next first one', status: 1, published: true, verified: true, application: ['WRW'], dataset_id: 'c867138c-eccf-4e57-8aa2-b62b87800ddh')
      }

      it 'Show list of all widgets' do
        get '/widget?status=all'

        expect(status).to    eq(200)
        expect(json.size).to eq(6)
      end

      it 'Show list of widgets with pending status' do
        get '/widget?status=pending'

        expect(status).to    eq(200)
        expect(json.size).to eq(1)
      end

      it 'Show list of widgets with active status' do
        get '/widget?status=active'

        expect(status).to    eq(200)
        expect(json.size).to eq(3)
      end

      it 'Show list of widgets with disabled status' do
        get '/widget?status=disabled'

        expect(status).to    eq(200)
        expect(json.size).to eq(1)
      end

      it 'Show list of widgets with published status true' do
        get '/widget?published=true'

        expect(status).to eq(200)
        expect(json.size).to                          eq(3)
        expect(json[0]['attributes']['published']).to eq(true)
      end

      it 'Show list of widgets with published status false' do
        get '/widget?published=false'

        expect(status).to eq(200)
        expect(json.size).to                          eq(3)
        expect(json[0]['attributes']['published']).to eq(false)
      end

      it 'Show list of widgets with verified status false' do
        get '/widget?verified=false'

        expect(status).to eq(200)
        expect(json.size).to                         eq(2)
        expect(json[0]['attributes']['verified']).to eq(false)
      end

      it 'Show list of widgets with verified status true' do
        get '/widget?verified=true'

        expect(status).to eq(200)
        expect(json.size).to                         eq(4)
        expect(json[0]['attributes']['verified']).to eq(true)
      end

      it 'Show list of widgets for app GFW' do
        get '/widget?app=GFw'

        expect(status).to eq(200)
        expect(json.size).to eq(2)
      end

      it 'Show list of widgets for app WRW' do
        get '/widget?app=wrw'

        expect(status).to eq(200)
        expect(json.size).to eq(2)
      end

      it 'Show blank list of widgets for not existing app' do
        get '/widget?app=notexisting'

        expect(status).to eq(200)
        expect(json.size).to eq(0)
      end

      it 'Show blank list of widgets for not existing app' do
        get '/widget?app=all'

        expect(status).to eq(200)
        expect(json.size).to eq(3)
      end

      it 'Show list of widgets with template true' do
        get '/widget?template=true'

        expect(status).to eq(200)
        expect(json.size).to                         eq(1)
        expect(json[0]['attributes']['template']).to eq(true)
      end

      it 'Show list of widgets with default true' do
        get '/widget?default=true'

        expect(status).to eq(200)
        expect(json.size).to                        eq(1)
        expect(json[0]['attributes']['default']).to eq(true)
      end

      it 'Show list of widgets with default false' do
        get '/widget?default=false'

        expect(status).to eq(200)
        expect(json.size).to                        eq(2)
        expect(json[0]['attributes']['default']).to eq(false)
      end

      it 'Show list of widgets for a specific dataset' do
        get '/widget?dataset=c547146d-de0c-47ff-a406-5125667fd5e7'

        expect(status).to eq(200)
        expect(json.size).to                          eq(1)
        expect(json[0]['attributes']['dataset']).to eq('c547146d-de0c-47ff-a406-5125667fd5e7')
      end

      it 'Show blank list of widgets for a non existing dataset' do
        get '/widget?dataset=c547146d-de0c-47ff-a406-5125667fd5e9'

        expect(status).to eq(200)
        expect(json.size).to eq(0)
      end

      it 'Show list of widgets for a specific dataset using url' do
        get '/dataset/c547146d-de0c-47ff-a406-5125667fd5e7/widget'

        expect(status).to eq(200)
        expect(json.size).to                          eq(1)
        expect(json[0]['attributes']['dataset']).to eq('c547146d-de0c-47ff-a406-5125667fd5e7')
      end

      it 'Filter by existing dataset using url and app' do
        get '/dataset/c547146d-de0c-47ff-a406-5125667fd5e7/widget?app=gfw'

        expect(status).to eq(200)
        expect(json.size).to eq(1)
      end

      it 'Filter by existing dataset using url and non existing app' do
        get '/dataset/c547146d-de0c-47ff-a406-5125667fd5e7/widget?app=wrw'

        expect(status).to eq(200)
        expect(json.size).to eq(0)
      end

      it 'Show blank list of widgets for a non existing dataset using url' do
        get '/dataset/c547146d-de0c-47ff-a406-5125667fd5e9/widget'

        expect(status).to eq(200)
        expect(json.size).to eq(0)
      end

      it 'Show list of widgets' do
        get '/widget'

        expect(status).to    eq(200)
        expect(json.size).to eq(3)
      end

      it 'Filter by dataset ids' do
        post '/widget/find-by-ids', params: { "widget": { "ids": ["c547146d-de0c-47ff-a406-5125667fd5e7", "c547146d-de0c-47ff-a406-5125667fd5e6"] } }

        expect(status).to eq(200)
        expect(json.size).to eq(2)
      end

      it 'Filter by dataset ids and apps' do
        post '/widget/find-by-ids', params: { "widget": { "ids": ["c547146d-de0c-47ff-a406-5125667fd5e7", "c547146d-de0c-47ff-a406-5125667fd5e6"], "app": ["wrw", "gfw"] } }

        expect(status).to eq(200)
        expect(json.size).to eq(2)
      end

      it 'Filter by dataset ids and apps' do
        post '/widget/find-by-ids', params: { "widget": { "ids": ["c547146d-de0c-47ff-a406-5125667fd5e7", "c547146d-de0c-47ff-a406-5125667fd5e6"], "app": ["prep", "test", "gfw"] } }

        expect(status).to eq(200)
        expect(json.size).to eq(2)
      end

      it 'Filter by dataset ids and apps' do
        post '/widget/find-by-ids', params: { "widget": { "ids": ["c547146d-de0c-47ff-a406-5125667fd5e7", "c547146d-de0c-47ff-a406-5125667fd5e6"], "app": ["test"] } }

        expect(status).to eq(200)
        expect(json.size).to eq(1)
      end

      it 'Filter by dataset ids and apps' do
        post '/widget/find-by-ids', params: { "widget": { "ids": ["c547146d-de0c-47ff-a406-5125667fd5e7", "c547146d-de0c-47ff-a406-5125667fd5e6"], "app": ["prep"] } }

        expect(status).to eq(200)
        expect(json.size).to eq(0)
      end

      it 'Filter by non existing dataset ids' do
        post '/widget/find-by-ids', params: { "widget": { "ids": ["c867138c-eccf-4e57-8aa2-b62b87800ddx"] } }

        expect(status).to eq(200)
        expect(json.size).to eq(0)
      end

      it 'Show blank list of widgets for all apps and second page (for total items 6)' do
        get '/widget?page[number]=2&page[size]=10&status=all'

        expect(status).to eq(200)
        expect(json.size).to eq(0)
      end

      it 'Show list of widgets for all apps first page' do
        get '/widget?page[number]=1&page[size]=10&status=all'

        expect(status).to eq(200)
        expect(json.size).to eq(6)
      end

      it 'Show list of widgets for all apps first page with per pege param' do
        get '/widget?page[number]=1&page[size]=3&status=all'

        expect(status).to eq(200)
        expect(json.size).to eq(3)
      end

      it 'Show list of widgets for all apps second page with per pege param' do
        get '/widget?page[number]=2&page[size]=3&status=all'

        expect(status).to eq(200)
        expect(json.size).to eq(3)
      end

      it 'Show list of widgets for all apps sort by name' do
        get '/widget?sort=name&status=all'

        expect(status).to eq(200)
        expect(json.size).to eq(6)
        expect(json[0]['attributes']['name']).to eq('AAA Widget one')
      end

      it 'Show list of widgets for all apps sort by name DESC' do
        get '/widget?sort=-name&status=all'

        expect(status).to eq(200)
        expect(json.size).to eq(6)
        expect(json[0]['attributes']['name']).to eq('ZZZ Next first one')
      end
    end
  end
end
