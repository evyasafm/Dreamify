"""
Figma REST API Integration

This module provides an interface to create and manipulate Figma designs
programmatically using the Figma REST API.
"""

import requests
import json
from typing import Dict, List, Optional, Any
from dataclasses import dataclass


@dataclass
class FigmaNode:
    """Represents a Figma node"""
    type: str
    name: str
    properties: Dict[str, Any]
    children: List['FigmaNode'] = None

    def to_dict(self) -> Dict[str, Any]:
        """Convert to Figma API format"""
        node_dict = {
            'type': self.type,
            'name': self.name,
            **self.properties
        }
        if self.children:
            node_dict['children'] = [child.to_dict() for child in self.children]
        return node_dict


class FigmaAPI:
    """Figma REST API client"""

    BASE_URL = 'https://api.figma.com/v1'

    def __init__(self, access_token: str):
        """
        Initialize Figma API client

        Args:
            access_token: Figma Personal Access Token
                         Get from: https://www.figma.com/developers/api#access-tokens
        """
        self.access_token = access_token
        self.headers = {
            'X-Figma-Token': access_token,
            'Content-Type': 'application/json'
        }

    def create_file(self, name: str) -> Dict[str, Any]:
        """
        Create a new Figma file

        Note: File creation via API is limited. This is a placeholder.
        In practice, you need to use the Figma Web API or create files manually.
        """
        # Figma API doesn't support direct file creation via REST API
        # Users need to create a file first and get its key
        raise NotImplementedError(
            "Figma REST API doesn't support file creation. "
            "Please create a file in Figma and use its file key."
        )

    def get_file(self, file_key: str) -> Dict[str, Any]:
        """Get Figma file data"""
        url = f"{self.BASE_URL}/files/{file_key}"
        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        return response.json()

    def create_component_in_file(self, file_key: str, page_name: str, nodes: List[FigmaNode]) -> bool:
        """
        Create components in a Figma file

        Note: Direct component creation via REST API is limited.
        This method demonstrates the structure but may require using
        Figma Plugins or the Web API for full functionality.
        """
        # The Figma REST API is primarily read-only
        # For write operations, we need to use:
        # 1. Figma Plugins API (runs inside Figma)
        # 2. Figma Web API (requires OAuth)

        print("⚠️  Note: Figma REST API is read-only.")
        print("To create designs from code, consider:")
        print("1. Using a Figma Plugin")
        print("2. Generating Figma Plugin code")
        print("3. Using third-party services like Anima or Bravo Studio")

        return False

    def get_component_sets(self, file_key: str) -> List[Dict[str, Any]]:
        """Get component sets from a file"""
        file_data = self.get_file(file_key)
        components = []

        def traverse(node):
            if node.get('type') == 'COMPONENT_SET':
                components.append(node)
            for child in node.get('children', []):
                traverse(child)

        traverse(file_data['document'])
        return components


class FigmaPluginGenerator:
    """
    Generates Figma Plugin code that can create designs

    Since the Figma REST API is read-only, we generate plugin code
    that can be run inside Figma to create designs programmatically.
    """

    def generate_plugin_code(self, nodes: List[FigmaNode], frame_name: str = "iOS Screen") -> str:
        """
        Generate Figma Plugin code to create the design

        Args:
            nodes: List of Figma nodes to create
            frame_name: Name of the root frame

        Returns:
            TypeScript code for a Figma plugin
        """

        code = f'''// This code runs inside Figma
// To use: Plugins -> Development -> New Plugin -> Run
// Paste this code in the plugin editor

figma.showUI(__html__, {{ width: 400, height: 300 }});

async function createDesign() {{
  const frame = figma.createFrame();
  frame.name = "{frame_name}";
  frame.resize(375, 812); // iPhone size
  frame.x = 0;
  frame.y = 0;

  // Set white background
  frame.fills = [{{
    type: 'SOLID',
    color: {{ r: 1, g: 1, b: 1 }}
  }}];

'''

        # Generate code for each node
        y_position = 0
        for i, node in enumerate(nodes):
            node_code = self._generate_node_code(node, i, y_position)
            code += node_code
            y_position += 60  # Spacing between elements

        code += '''
  figma.currentPage.appendChild(frame);
  figma.viewport.scrollAndZoomIntoView([frame]);

  figma.ui.postMessage({ type: 'creation-complete' });
}

createDesign();

// Close plugin when done
figma.ui.onmessage = msg => {
  if (msg.type === 'close') {
    figma.closePlugin();
  }
};
'''

        return code

    def _generate_node_code(self, node: FigmaNode, index: int, y_pos: int) -> str:
        """Generate code for a single node"""

        if node.type == 'TEXT':
            return self._generate_text_code(node, index, y_pos)
        elif node.type == 'RECTANGLE':
            return self._generate_rectangle_code(node, index, y_pos)
        elif node.type == 'FRAME':
            return self._generate_frame_code(node, index, y_pos)
        else:
            return f"  // Unsupported node type: {node.type}\n"

    def _generate_text_code(self, node: FigmaNode, index: int, y_pos: int) -> str:
        """Generate code for a text node"""
        text = node.properties.get('characters', 'Text')
        font_size = node.properties.get('fontSize', 16)
        color = node.properties.get('color', {'r': 0, 'g': 0, 'b': 0})

        return f'''
  const text{index} = figma.createText();
  await figma.loadFontAsync({{ family: "Inter", style: "Regular" }});
  text{index}.characters = "{text}";
  text{index}.fontSize = {font_size};
  text{index}.fills = [{{
    type: 'SOLID',
    color: {{ r: {color['r']}, g: {color['g']}, b: {color['b']} }}
  }}];
  text{index}.x = 20;
  text{index}.y = {y_pos};
  frame.appendChild(text{index});
'''

    def _generate_rectangle_code(self, node: FigmaNode, index: int, y_pos: int) -> str:
        """Generate code for a rectangle node"""
        width = node.properties.get('width', 100)
        height = node.properties.get('height', 100)
        color = node.properties.get('color', {'r': 0.5, 'g': 0.5, 'b': 0.5})
        corner_radius = node.properties.get('cornerRadius', 0)

        return f'''
  const rect{index} = figma.createRectangle();
  rect{index}.resize({width}, {height});
  rect{index}.fills = [{{
    type: 'SOLID',
    color: {{ r: {color['r']}, g: {color['g']}, b: {color['b']} }}
  }}];
  rect{index}.cornerRadius = {corner_radius};
  rect{index}.x = 20;
  rect{index}.y = {y_pos};
  frame.appendChild(rect{index});
'''

    def _generate_frame_code(self, node: FigmaNode, index: int, y_pos: int) -> str:
        """Generate code for a frame node"""
        width = node.properties.get('width', 200)
        height = node.properties.get('height', 200)

        return f'''
  const frame{index} = figma.createFrame();
  frame{index}.resize({width}, {height});
  frame{index}.x = 20;
  frame{index}.y = {y_pos};
  frame.appendChild(frame{index});
'''

    def save_plugin_code(self, code: str, output_path: str):
        """Save plugin code to a file"""
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(code)
        print(f"✅ Plugin code saved to: {output_path}")
        print("\nTo use:")
        print("1. Open Figma")
        print("2. Go to Plugins -> Development -> New Plugin")
        print("3. Choose 'Figma design'")
        print("4. Replace code.ts content with the generated code")
        print("5. Run the plugin")


class FigmaDesignExporter:
    """Export Figma design specifications"""

    @staticmethod
    def export_to_json(nodes: List[FigmaNode], output_path: str):
        """Export nodes to JSON format"""
        data = {
            'nodes': [node.to_dict() for node in nodes],
            'version': '1.0.0',
            'generator': 'iOS-to-Figma Converter'
        }

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)

        print(f"✅ Design exported to: {output_path}")

    @staticmethod
    def export_to_figma_url_scheme(nodes: List[FigmaNode]) -> str:
        """
        Generate Figma URL scheme for creating designs
        (This is a conceptual approach - actual implementation may vary)
        """
        # Figma URL schemes are limited
        # This is a placeholder for potential future functionality
        return "figma://new-file"
