require 'acceptance_helper'

module V1
  describe 'Widgets', type: :request do
    context 'Create, update and delete widgets' do
      let!(:settings) {{"marks": {
                        "type_test": "rect",
                        "from": {
                          "data_new": "table"
                      }}}}

      let!(:params) {{"widget": { "name": "First test widget" }}}

      let!(:params_faild) {{"widget": { "name": "Widget second one" }}}

      let!(:widget) {
        Widget.create!(name: 'Widget second one', application: ['gfw'])
      }

      let!(:widget_id)   { widget.id   }
      let!(:widget_slug) { widget.slug }

      let!(:update_params) {{"widget": { "name": "First test one update",
                                         "slug": "updated-first-test-widget" }
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
        expect(json_main['message']['name']).to eq(['has already been taken'])
        expect(json_main['message']['slug']).to eq(['has already been taken'])
      end

      it 'Allows to update widget' do
        put "/widget/#{widget_slug}", params: update_params

        expect(status).to eq(200)
        expect(json['id']).to                 be_present
        expect(json['attributes']['name']).to eq('First test one update')
        expect(json['attributes']['slug']).to eq('updated-first-test-widget')
      end

      it 'Allows to delete widget by id' do
        delete "/widget/#{widget_id}"

        expect(status).to eq(200)
        expect(json_main['message']).to        eq('Widget deleted')
        expect(Widget.where(id: widget_id)).to be_empty
      end

      it 'Allows to delete widget by slug' do
        delete "/widget/#{widget_slug}"

        expect(status).to eq(200)
        expect(json_main['message']).to                 eq('Widget deleted')
        expect(Widget.where(slug: widget_slug)).to be_empty
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
