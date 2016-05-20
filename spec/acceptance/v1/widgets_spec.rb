require 'acceptance_helper'

module V1
  describe 'Widgets', type: :request do
    context 'Create, update and delete widgets' do
      let!(:settings) {{"marks": {
                        "type": "rect",
                        "from": {
                          "data": "table"
                      }}}}

      let!(:params) {{"widget": { "name": "First test widget", "layers_attributes": [{ "name": "Test layer second", "settings": Oj.dump(settings), "published": true, "status": 1 }] }}}

      let!(:params_faild) {{"widget": { "name": "Widget second one", "layers_attributes": [{ "name": "Test layer first", "settings": Oj.dump(settings) }] }}}

      let!(:widget) {
        Widget.create!(name: 'Widget second one', layers_attributes: [{ name: 'Test layer first', published: true, status: 1 }])
      }

      let!(:widget_id)   { widget.id              }
      let!(:widget_slug) { widget.slug            }
      let!(:layer_id)    { widget.layers.first.id }

      let!(:update_params) {{"widget": { "name": "First test one update",
                                         "slug": "updated-first-test-widget",
                                         "layers_attributes": [{ "id": layer_id, "name": "Test layer second", "settings": Oj.dump(settings) }] }
                           }}

      context 'List filters' do
        let!(:disabled_widget) {
          Widget.create!(name: 'Widget second second', slug: 'widget-second-second', status: 3, published: false)
        }

        let!(:enabled_widget) {
          Widget.create!(name: 'Widget one', status: 1, published: true)
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
          expect(json.size).to eq(1)
          expect(json[0]['published']).to eq(true)
        end

        it 'Show list of widgets with published status false' do
          get '/widgets?published=false'

          expect(status).to eq(200)
          expect(json.size).to eq(3)
          expect(json[0]['published']).to eq(false)
        end

        it 'Show list of widgets' do
          get '/widgets'

          expect(status).to eq(200)
          expect(json.size).to eq(1)
        end
      end

      it 'Show widget by slug' do
        get "/widgets/#{widget_slug}"

        expect(status).to eq(200)
        expect(json['slug']).to            eq('widget-second-one')
        expect(json['meta']['status']).to  eq('pending')
      end

      it 'Show widget by id' do
        get "/widgets/#{widget_id}"

        expect(status).to eq(200)
      end

      it 'Allows to create second widget' do
        post '/widgets', params: params

        expect(status).to eq(201)
        expect(json['id']).to                    be_present
        expect(json['slug']).to                  eq('first-test-widget')
        expect(json['layers'][0]['settings']).to eq(Oj.dump(settings))
      end

      it 'Name and slug validation' do
        post '/widgets', params: params_faild

        expect(status).to eq(422)
        expect(json['message']['layers.name']).to eq(['has already been taken'])
        expect(json['message']['name']).to        eq(['has already been taken'])
        expect(json['message']['slug']).to        eq(['has already been taken'])
      end

      it 'Allows to update widget' do
        put "/widgets/#{widget_slug}", params: update_params

        expect(status).to eq(200)
        expect(json['id']).to                be_present
        expect(json['name']).to              eq('First test one update')
        expect(json['slug']).to              eq('updated-first-test-widget')
        expect(json['layers'][0]['name']).to eq('Test layer second')
      end

      it 'Allows to delete widget by id' do
        delete "/widgets/#{widget_id}"

        expect(status).to eq(200)
        expect(json['message']).to eq('Widget deleted')
        expect(Widget.where(id: widget_id)).to be_empty
      end

      it 'Allows to delete widget by slug' do
        delete "/widgets/#{widget_slug}"

        expect(status).to eq(200)
        expect(json['message']).to eq('Widget deleted')
        expect(Widget.where(slug: widget_slug)).to be_empty
      end
    end
  end
end
