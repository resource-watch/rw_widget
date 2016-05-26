require 'acceptance_helper'

module V1
  describe 'Widgets', type: :request do
    context 'Create, update and delete widgets' do
      let!(:settings) {{"marks": {
                        "type": "rect",
                        "from": {
                          "data": "table"
                      }}}}

      let!(:params) {{"widget": { "name": "First test widget" }}}

      let!(:params_faild) {{"widget": { "name": "Widget second one" }}}

      let!(:widget) {
        Widget.create!(name: 'Widget second one')
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
          Widget.create!(name: 'Widget one', status: 1, published: true, verified: true)
        }

        let!(:unpublished_widget) {
          Widget.create!(name: 'Widget one unpublished', status: 1, published: false)
        }

        it 'Show list of all widgets' do
          get '/widgets?status=all'

          expect(status).to eq(200)
          expect(json.size).to eq(4)
        end

        it 'Show list of widgets with pending status' do
          get '/widgets?status=pending'

          expect(status).to eq(200)
          expect(json.size).to eq(1)
        end

        it 'Show list of widgets with active status' do
          get '/widgets?status=active'

          expect(status).to eq(200)
          expect(json.size).to eq(1)
        end

        it 'Show list of widgets with disabled status' do
          get '/widgets?status=disabled'

          expect(status).to eq(200)
          expect(json.size).to eq(1)
        end

        it 'Show list of widgets with published status true' do
          get '/widgets?published=true'

          expect(status).to eq(200)
          expect(json.size).to            eq(1)
          expect(json[0]['published']).to eq(true)
        end

        it 'Show list of widgets with published status false' do
          get '/widgets?published=false'

          expect(status).to eq(200)
          expect(json.size).to            eq(3)
          expect(json[0]['published']).to eq(false)
        end

        it 'Show list of widgets' do
          get '/widgets'

          expect(status).to    eq(200)
          expect(json.size).to eq(1)
        end
      end

      it 'Show widget by slug' do
        get "/widgets/#{widget_slug}"

        expect(status).to eq(200)
        expect(json['slug']).to           eq('widget-second-one')
        expect(json['meta']['status']).to eq('pending')
      end

      it 'Show widget by id' do
        get "/widgets/#{widget_id}"

        expect(status).to eq(200)
      end

      it 'Allows to create second widget' do
        post '/widgets', params: params

        expect(status).to eq(201)
        expect(json['id']).to   be_present
        expect(json['slug']).to eq('first-test-widget')
      end

      it 'Name and slug validation' do
        post '/widgets', params: params_faild

        expect(status).to eq(422)
        expect(json['message']['name']).to eq(['has already been taken'])
        expect(json['message']['slug']).to eq(['has already been taken'])
      end

      it 'Allows to update widget' do
        put "/widgets/#{widget_slug}", params: update_params

        expect(status).to eq(200)
        expect(json['id']).to   be_present
        expect(json['name']).to eq('First test one update')
        expect(json['slug']).to eq('updated-first-test-widget')
      end

      it 'Allows to delete widget by id' do
        delete "/widgets/#{widget_id}"

        expect(status).to eq(200)
        expect(json['message']).to             eq('Widget deleted')
        expect(Widget.where(id: widget_id)).to be_empty
      end

      it 'Allows to delete widget by slug' do
        delete "/widgets/#{widget_slug}"

        expect(status).to eq(200)
        expect(json['message']).to                 eq('Widget deleted')
        expect(Widget.where(slug: widget_slug)).to be_empty
      end

      context 'Save dataset_id from query' do
        let!(:widget_last) {
          Widget.create!(name: 'Widget last', status: 1, published: true, verified: true, layer_id: 'c547146d-de0c-47ff-a406-5125667fd5e1',
                         query_url: 'http://ec2-52-23-163-254.compute-1.amazonaws.com/query/c547146d-de0c-47ff-a406-5125667fd599?select[]=iso&order[]=-iso')
        }

        let!(:widget_last_id) { widget_last.id }

        it 'Show widget with dataset_id generated from query_url' do
          get "/widgets/#{widget_last_id}"

          expect(status).to eq(200)
          expect(json['slug']).to             eq('widget-last')
          expect(json['layer_id']).to         eq('c547146d-de0c-47ff-a406-5125667fd5e1')
          expect(json['dataset_id']).to       eq('c547146d-de0c-47ff-a406-5125667fd599')
          expect(json['meta']['verified']).to eq(true)
        end
      end
    end
  end
end
