import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import cytoscape from 'cytoscape';

export default class extends Controller {
  static targets = ["graphContainer"]

  connect() {
    this.init();
  }

  async init() {
    const tags = await this.fetchTags();
    this.renderGraph(tags);
  }

  async fetchTags() {
    try {
      const response = await get(`/api/v1/tags`, {
        responseKind: "json"
      });
      if (!response.ok) return [];
      return await response.json;
    } catch (error) {
      console.error("Error fetching tags:", error);
      return [];
    }
  }

  renderGraph(tags) {
    // Create nodes from tags
    const nodes = tags.map(tag => ({
      data: { id: `tag-${tag.id}`, label: tag.name, weight: tag.taggings_count }
    }));

    // Create some example edges - in a real app, you'd fetch relationships
    const edges = [];
    for (let i = 0; i < nodes.length; i++) {
      // Connect to a random node
      if (i < nodes.length - 1) {
        edges.push({
          data: {
            id: `edge-${i}`,
            source: nodes[i].data.id,
            target: nodes[i+1].data.id
          }
        });
      }
    }

    // Initialize cytoscape
    const cy = cytoscape({
      container: this.graphContainerTarget,
      elements: [...nodes, ...edges],
      style: [
        {
          selector: 'node',
          style: {
            'label': 'data(label)',
            'background-color': '#6c757d',
            'color': '#fff',
            'text-valign': 'center',
            'text-halign': 'center',
            'width': 'mapData(weight, 1, 10, 30, 60)',
            'height': 'mapData(weight, 1, 10, 30, 60)',
            'font-size': '10px'
          }
        },
        {
          selector: 'edge',
          style: {
            'width': 2,
            'line-color': '#ccc',
            'curve-style': 'bezier'
          }
        }
      ],
      layout: {
        name: 'cose', // Using built-in cose (Compound Spring Embedder) - force-directed algorithm
        animate: true,
        refresh: 20,
        fit: true,
        padding: 30,
        randomize: true,
        nodeOverlap: 20,
        componentSpacing: 100,
        nodeRepulsion: 400000,
        edgeElasticity: 100,
        nestingFactor: 5
      }
    });

    // Add interactions
    cy.on('tap', 'node', event => {
      const node = event.target;
      console.log('Clicked on:', node.data('label'));
      // You can add more interactions here
    });
  }
}