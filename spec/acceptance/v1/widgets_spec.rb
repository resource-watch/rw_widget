require 'acceptance_helper'

module V1
  describe 'Widgets', type: :request do
    context 'Create, update and delete widgets' do
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
          Widget.create!(name: 'Widget one', status: 1, published: true, verified: true, application: ['Gfw', 'wrw'], dataset_id: 'c547146d-de0c-47ff-a406-5125667fd5e6', default: true)
        }

        let!(:enabled_widget_2) {
          Widget.create!(name: 'Widget one two', status: 1, published: true, verified: true, application: ['Gfw', 'test'], dataset_id: 'c547146d-de0c-47ff-a406-5125667fd5e7', template: true)
        }

        let!(:unpublished_widget) {
          Widget.create!(name: 'Widget one unpublished', status: 1, published: false, verified: true)
        }

        let!(:next_widget) {
          Widget.create!(name: 'Next first one', status: 1, published: true, verified: true, application: ['WRW'], dataset_id: 'c867138c-eccf-4e57-8aa2-b62b87800ddh')
        }

        it 'Show list of all widgets' do
          get '/widget?status=all'

          expect(status).to    eq(200)
          expect(json.size).to eq(6)
        end
      end

      it 'Show widget by slug' do
        get "/widget/#{widget_slug}"

        expect(status).to eq(200)
        expect(json['attributes']['slug']).to  eq('widget-second-one')
        expect(json_main['meta']['status']).to eq('pending')
      end

      it 'Show widget by id' do
        get "/widget/#{widget_id}"

        expect(status).to eq(200)
      end

      it 'Allows to create second widget' do
        post '/widget', params: params

        expect(status).to eq(201)
        expect(json['id']).to                 be_present
        expect(json['attributes']['slug']).to eq('first-test-widget')
      end

      it 'Name and slug validation' do
        post '/widget', params: params_faild

        expect(status).to eq(422)
        expect(json_main['errors'][0]['title']).to eq(['Name has already been taken', 'Slug has already been taken'])
      end

      it 'Allows to update widget' do
        put "/widget/#{widget_slug}", params: update_params

        expect(status).to eq(200)
        expect(json['id']).to                 be_present
        expect(json['attributes']['name']).to eq('First test one update')
        expect(json['attributes']['slug']).to eq('updated-first-test-widget')
      end

      it 'Allows to update widget from internal microservice' do
        patch "/widget/#{widget_slug}", params: {"loggedUser": {"id": "microservice"},
                                                 "widget": {"status": 1}}

        expect(status).to eq(200)
        expect(Widget.find_by(slug: widget_slug).status).to  eq(1)
        expect(Widget.find_by(slug: widget_slug).user_id).to eq('3242-32442-432')
      end

      it 'Allows to delete widget by id' do
        delete "/widget/#{widget_id}", params: { "loggedUser": "{\"role\": \"manager\", \"extraUserData\": { \"apps\": [\"gfw\",\"prep\"] }, \"id\": \"3242-32442-432\"}"}

        expect(status).to eq(200)
        expect(json_main['message']).to        eq('Widget deleted')
        expect(Widget.where(id: widget_id)).to be_empty
      end

      it 'Allows to delete widget by slug' do
        delete "/widget/#{widget_slug}", params: { "loggedUser": {"role": "manager", "extraUserData": { "apps": ["gfw","prep"] }, "id": "3242-32442-432"}}

        expect(status).to eq(200)
        expect(json_main['message']).to            eq('Widget deleted')
        expect(Widget.where(slug: widget_slug)).to be_empty
      end

      context 'Check roles' do
        it 'Do not allows to create widget by an user' do
          post '/widget', params: {"loggedUser": {"role": "user", "extraUserData": { "apps": ["gfw","prep"] }, "id": "3242-32442-432"},
                                    "widget": {"name": "Widget", "application": ["gfw"] }}

          expect(status).to eq(401)
          expect(json_main['errors'][0]['title']).to eq('Not authorized!')
        end

        it 'Do not allows to create widget by manager user if not in apps' do
          post '/widget', params: {"loggedUser": {"role": "manager", "extraUserData": { "apps": ["gfw","prep"] }, "id": "3242-32442-432"},
                                    "widget": {"name": "Widget", "application": ["wri"] }}

          expect(status).to eq(401)
          expect(json_main['errors'][0]['title']).to eq('Not authorized!')
        end

        it 'Allows to update widget by admin user if in apps' do
          patch "/widget/#{widget_id}", params: {"loggedUser": {"role": "Admin", "extraUserData": { "apps": ["gfw", "wrw","prep"] }, "id": "3242-32442-436"},
                                                 "widget": {"name": "Carto test api Widget"}}

          expect(status).to eq(200)
          expect(json_attr['name']).to        eq('Carto test api Widget')
          expect(json_attr['application']).to eq(["gfw"])
        end

        it 'Do not allow to update widget by admin user if not in apps' do
          patch "/widget/#{widget_id}", params: {"loggedUser": {"role": "Admin", "extraUserData": { "apps": ["prep"] }, "id": "3242-32442-436"},
                                                 "widget": {"application": ["prep", "gfw"],
                                                            "name": "Carto test api"}}

          expect(status).to eq(401)
          expect(json_main['errors'][0]['title']).to eq('Not authorized!')
        end

        it 'Allows to update widget by superadmin user' do
          patch "/widget/#{widget_id}", params: {"loggedUser": {"role": "Superadmin", "extraUserData": { }, "id": "3242-32442-436"},
                                                 "widget": {"application": ["testapp"],
                                                            "name": "Widget"}}

          expect(status).to eq(200)
          expect(json_attr['name']).to         eq('Widget')
          expect(json_attr['application']).to  eq(["testapp"])
        end

        it 'Allows to update widget by admin user if in apps changing apps' do
          patch "/widget/#{widget_id}", params: {"loggedUser": {"role": "Admin", "extraUserData": { "apps": ["gfw", "wrw", "prep","testapp"] }, "id": "3242-32442-436"},
                                                 "widget": {"application": ["gfw", "wrw" ,"testapp"],
                                                            "name": "Widget additional apps"}}

          expect(status).to eq(200)
          expect(json_attr['name']).to         eq('Widget additional apps')
          expect(json_attr['application']).to  eq(["gfw", "wrw", "testapp"])
        end
      end

      context 'Save dataset_id from query' do
        let!(:widget_last) {
          Widget.create!(name: 'Widget last', status: 1, published: true, verified: true, layer_id: 'c547146d-de0c-47ff-a406-5125667fd5e1',
                         query_url: 'http://ec2-52-23-163-254.compute-1.amazonaws.com/query/c547146d-de0c-47ff-a406-5125667fd599?select[]=iso&order[]=-iso')
        }

        let!(:widget_last_id) { widget_last.id }

        it 'Show widget with dataset_id generated from query_url' do
          get "/widget/#{widget_last_id}"

          expect(status).to eq(200)
          expect(json['attributes']['slug']).to      eq('widget-last')
          expect(json['attributes']['layerId']).to   eq('c547146d-de0c-47ff-a406-5125667fd5e1')
          expect(json['attributes']['dataset']).to eq('c547146d-de0c-47ff-a406-5125667fd599')
          expect(json_main['meta']['verified']).to   eq(true)
        end
      end
    end
  end
end
