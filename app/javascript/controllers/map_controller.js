import { Controller } from "@hotwired/stimulus";
import mapboxgl from '!mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import GeoJSON from 'geojson'

export default class extends Controller {
  static values = { apiKey: String, markers: String }

  connect() {
    const mapElement = this.element;

    const shareholdersGeoJson = GeoJSON.parse(JSON.parse(this.markersValue), {Point: ['lat', 'lng']});

    if (mapElement) {
      mapboxgl.accessToken = this.apiKeyValue;
      const map = new mapboxgl.Map({
        container: 'map',
        style: 'mapbox://styles/manue-1067/cko9var276gb017qbghty0pa9',
        center: [24.628637, 35.018786],
        zoom: 1.5
      });

      map.addControl(new mapboxgl.NavigationControl());

      const source = 'shareholders';

      // see https://docs.mapbox.com/mapbox-gl-js/example/cluster/
      map.on('load', function () {
        map.addSource(source, {
          type: 'geojson',
          data: shareholdersGeoJson,
          cluster: true,
          clusterMaxZoom: 50,
          clusterRadius: 50
        });

        map.addLayer({
          id: 'clusters',
          type: 'circle',
          source: source,
          filter: ['has', 'point_count'],
          paint: {
            'circle-color': [
              'step',
              ['get', 'point_count'],
              '#E6DFFF',
              100,
              '#B29FFF',
              750,
              '#714EFF'
            ],
            'circle-radius': [
              'step',
              ['get', 'point_count'],
              20,
              100,
              30,
              750,
              40
            ]
          }
        });

        map.addLayer({
          id: 'cluster-count',
          type: 'symbol',
          source: source,
          filter: ['has', 'point_count'],
          layout: {
            'text-field': '{point_count_abbreviated}',
            'text-font': ['Gilroy ExtraBold', 'Arial Unicode MS Bold'],
            'text-size': 16
          }
        });

        map.on('click', 'clusters', function (e) {
          var features = map.queryRenderedFeatures(e.point, {
            layers: ['clusters']
          });
          var clusterId = features[0].properties.cluster_id;
          map.getSource(source).getClusterExpansionZoom(
            clusterId,
            function (err, zoom) {
              if (err) return;
              map.easeTo({
                center: features[0].geometry.coordinates,
                zoom: zoom
              });
            }
          );
        });
      });
    }
  }
}
