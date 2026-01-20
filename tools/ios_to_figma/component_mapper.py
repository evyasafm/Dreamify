"""
iOS to Figma Component Mapper

This module maps iOS UI components (SwiftUI/UIKit) to Figma design elements.
"""

from typing import List, Dict, Any, Optional
from ios_parser import UIComponent
from figma_api import FigmaNode
import re


class ColorConverter:
    """Convert iOS colors to Figma RGB format"""

    COLOR_MAP = {
        # SwiftUI System Colors
        '.blue': {'r': 0.0, 'g': 0.478, 'b': 1.0},
        '.red': {'r': 1.0, 'g': 0.231, 'b': 0.188},
        '.green': {'r': 0.204, 'g': 0.780, 'b': 0.349},
        '.yellow': {'r': 1.0, 'g': 0.800, 'b': 0.0},
        '.orange': {'r': 1.0, 'g': 0.584, 'b': 0.0},
        '.purple': {'r': 0.686, 'g': 0.322, 'b': 0.871},
        '.pink': {'r': 1.0, 'g': 0.176, 'b': 0.333},
        '.black': {'r': 0.0, 'g': 0.0, 'b': 0.0},
        '.white': {'r': 1.0, 'g': 1.0, 'b': 1.0},
        '.gray': {'r': 0.557, 'g': 0.557, 'b': 0.576},
        'Color.blue': {'r': 0.0, 'g': 0.478, 'b': 1.0},
        'Color.red': {'r': 1.0, 'g': 0.231, 'b': 0.188},
        'Color.green': {'r': 0.204, 'g': 0.780, 'b': 0.349},
        'Color.white': {'r': 1.0, 'g': 1.0, 'b': 1.0},
        'Color.black': {'r': 0.0, 'g': 0.0, 'b': 0.0},
        # UIKit Colors
        'UIColor.blue': {'r': 0.0, 'g': 0.478, 'b': 1.0},
        'UIColor.red': {'r': 1.0, 'g': 0.231, 'b': 0.188},
        'UIColor.systemBlue': {'r': 0.0, 'g': 0.478, 'b': 1.0},
        'UIColor.systemRed': {'r': 1.0, 'g': 0.231, 'b': 0.188},
        'UIColor.systemGreen': {'r': 0.204, 'g': 0.780, 'b': 0.349},
        'UIColor.white': {'r': 1.0, 'g': 1.0, 'b': 1.0},
        'UIColor.black': {'r': 0.0, 'g': 0.0, 'b': 0.0},
        'UIColor.gray': {'r': 0.557, 'g': 0.557, 'b': 0.576},
    }

    @classmethod
    def convert(cls, color_string: str) -> Dict[str, float]:
        """Convert iOS color to Figma RGB"""
        # Clean the string
        color_string = color_string.strip()

        # Check color map
        if color_string in cls.COLOR_MAP:
            return cls.COLOR_MAP[color_string]

        # Parse RGB/RGBA
        rgb_match = re.search(r'Color\(red:\s*([\d.]+),\s*green:\s*([\d.]+),\s*blue:\s*([\d.]+)', color_string)
        if rgb_match:
            return {
                'r': float(rgb_match.group(1)),
                'g': float(rgb_match.group(2)),
                'b': float(rgb_match.group(3))
            }

        # Parse UIColor RGB
        uicolor_match = re.search(r'UIColor\(red:\s*([\d.]+),\s*green:\s*([\d.]+),\s*blue:\s*([\d.]+)', color_string)
        if uicolor_match:
            return {
                'r': float(uicolor_match.group(1)),
                'g': float(uicolor_match.group(2)),
                'b': float(uicolor_match.group(3))
            }

        # Default to black
        return {'r': 0.0, 'g': 0.0, 'b': 0.0}


class FontConverter:
    """Convert iOS fonts to Figma font specifications"""

    FONT_SIZE_MAP = {
        '.largeTitle': 34,
        '.title': 28,
        '.title2': 22,
        '.title3': 20,
        '.headline': 17,
        '.body': 17,
        '.callout': 16,
        '.subheadline': 15,
        '.footnote': 13,
        '.caption': 12,
        '.caption2': 11,
    }

    @classmethod
    def convert_size(cls, font_string: str) -> int:
        """Convert iOS font to size"""
        # Check system font sizes
        if font_string in cls.FONT_SIZE_MAP:
            return cls.FONT_SIZE_MAP[font_string]

        # Parse explicit size
        size_match = re.search(r'\.system\(size:\s*([\d.]+)', font_string)
        if size_match:
            return int(float(size_match.group(1)))

        # Parse custom font size
        custom_match = re.search(r'Font\.custom\([^,]+,\s*size:\s*([\d.]+)', font_string)
        if custom_match:
            return int(float(custom_match.group(1)))

        # Parse UIFont
        uifont_match = re.search(r'UIFont\.systemFont\(ofSize:\s*([\d.]+)', font_string)
        if uifont_match:
            return int(float(uifont_match.group(1)))

        # Default
        return 17

    @classmethod
    def is_bold(cls, modifiers: List[Dict[str, Any]]) -> bool:
        """Check if font is bold"""
        for modifier in modifiers:
            if modifier['name'] == 'bold':
                return True
            if modifier['name'] == 'font' and 'bold' in str(modifier.get('value', '')).lower():
                return True
        return False

    @classmethod
    def is_italic(cls, modifiers: List[Dict[str, Any]]) -> bool:
        """Check if font is italic"""
        for modifier in modifiers:
            if modifier['name'] == 'italic':
                return True
        return False


class LayoutConverter:
    """Convert iOS layout to Figma positioning"""

    @classmethod
    def parse_frame(cls, frame_string: str) -> Dict[str, float]:
        """Parse iOS frame/CGRect to Figma dimensions"""
        # Parse .frame(width: x, height: y)
        match = re.search(r'width:\s*([\d.]+).*?height:\s*([\d.]+)', frame_string)
        if match:
            return {
                'width': float(match.group(1)),
                'height': float(match.group(2))
            }

        # Parse CGRect(x: , y: , width: , height: )
        cgrect_match = re.search(
            r'CGRect\(x:\s*([\d.]+),\s*y:\s*([\d.]+),\s*width:\s*([\d.]+),\s*height:\s*([\d.]+)\)',
            frame_string
        )
        if cgrect_match:
            return {
                'x': float(cgrect_match.group(1)),
                'y': float(cgrect_match.group(2)),
                'width': float(cgrect_match.group(3)),
                'height': float(cgrect_match.group(4))
            }

        return {}

    @classmethod
    def parse_padding(cls, padding_string: str) -> Dict[str, float]:
        """Parse iOS padding"""
        # Parse single value
        if padding_string.replace('.', '').isdigit():
            value = float(padding_string)
            return {'top': value, 'right': value, 'bottom': value, 'left': value}

        # Parse EdgeInsets
        insets_match = re.search(
            r'EdgeInsets\(top:\s*([\d.]+),\s*leading:\s*([\d.]+),\s*bottom:\s*([\d.]+),\s*trailing:\s*([\d.]+)\)',
            padding_string
        )
        if insets_match:
            return {
                'top': float(insets_match.group(1)),
                'left': float(insets_match.group(2)),
                'bottom': float(insets_match.group(3)),
                'right': float(insets_match.group(4))
            }

        return {}


class ComponentMapper:
    """Maps iOS UI components to Figma nodes"""

    def __init__(self):
        self.color_converter = ColorConverter()
        self.font_converter = FontConverter()
        self.layout_converter = LayoutConverter()

    def map_components(self, ios_components: List[UIComponent]) -> List[FigmaNode]:
        """Map iOS components to Figma nodes"""
        figma_nodes = []

        for component in ios_components:
            figma_node = self._map_component(component)
            if figma_node:
                figma_nodes.append(figma_node)

        return figma_nodes

    def _map_component(self, component: UIComponent) -> Optional[FigmaNode]:
        """Map a single iOS component to Figma node"""

        if component.type == 'Text':
            return self._map_text(component)
        elif component.type == 'Button':
            return self._map_button(component)
        elif component.type == 'Image':
            return self._map_image(component)
        elif component.type in ['Rectangle', 'Circle', 'RoundedRectangle']:
            return self._map_shape(component)
        elif component.type in ['VStack', 'HStack', 'ZStack']:
            return self._map_stack(component)
        elif component.type.startswith('UI'):  # UIKit components
            return self._map_uikit_component(component)

        return None

    def _map_text(self, component: UIComponent) -> FigmaNode:
        """Map Text component to Figma TEXT node"""
        properties = {
            'characters': component.properties.get('text', 'Text'),
            'fontSize': 17,  # Default
            'fills': [{'type': 'SOLID', 'color': {'r': 0, 'g': 0, 'b': 0}}]
        }

        # Apply modifiers
        for modifier in component.modifiers:
            if modifier['name'] == 'font':
                properties['fontSize'] = self.font_converter.convert_size(modifier.get('value', ''))
            elif modifier['name'] == 'foregroundColor':
                color = self.color_converter.convert(modifier.get('value', ''))
                properties['fills'] = [{'type': 'SOLID', 'color': color}]
            elif modifier['name'] == 'frame':
                frame = self.layout_converter.parse_frame(modifier.get('value', ''))
                properties.update(frame)

        # Check for bold/italic
        if self.font_converter.is_bold(component.modifiers):
            properties['fontWeight'] = 700

        return FigmaNode(
            type='TEXT',
            name=f"Text: {properties['characters'][:20]}",
            properties=properties
        )

    def _map_button(self, component: UIComponent) -> FigmaNode:
        """Map Button to Figma FRAME with text"""
        # Create a frame for the button
        properties = {
            'width': 120,
            'height': 44,
            'fills': [{'type': 'SOLID', 'color': {'r': 0.0, 'g': 0.478, 'b': 1.0}}],
            'cornerRadius': 8
        }

        # Apply modifiers
        for modifier in component.modifiers:
            if modifier['name'] == 'background':
                color = self.color_converter.convert(modifier.get('value', ''))
                properties['fills'] = [{'type': 'SOLID', 'color': color}]
            elif modifier['name'] == 'frame':
                frame = self.layout_converter.parse_frame(modifier.get('value', ''))
                properties.update(frame)
            elif modifier['name'] == 'cornerRadius':
                properties['cornerRadius'] = float(modifier.get('value', 8))

        return FigmaNode(
            type='FRAME',
            name='Button',
            properties=properties
        )

    def _map_image(self, component: UIComponent) -> FigmaNode:
        """Map Image to Figma RECTANGLE (placeholder)"""
        properties = {
            'width': 100,
            'height': 100,
            'fills': [{'type': 'SOLID', 'color': {'r': 0.9, 'g': 0.9, 'b': 0.9}}],
            'cornerRadius': 0
        }

        # Apply modifiers
        for modifier in component.modifiers:
            if modifier['name'] == 'frame':
                frame = self.layout_converter.parse_frame(modifier.get('value', ''))
                properties.update(frame)
            elif modifier['name'] == 'cornerRadius':
                properties['cornerRadius'] = float(modifier.get('value', 0))

        image_name = component.properties.get('systemName') or component.properties.get('name', 'Image')

        return FigmaNode(
            type='RECTANGLE',
            name=f'Image: {image_name}',
            properties=properties
        )

    def _map_shape(self, component: UIComponent) -> FigmaNode:
        """Map Shape to Figma shape node"""
        properties = {
            'width': 100,
            'height': 100,
            'fills': [{'type': 'SOLID', 'color': {'r': 0.7, 'g': 0.7, 'b': 0.7}}],
            'cornerRadius': 0
        }

        if component.type == 'Circle':
            properties['cornerRadius'] = 50
        elif component.type == 'RoundedRectangle':
            properties['cornerRadius'] = component.properties.get('cornerRadius', 8)

        # Apply modifiers
        for modifier in component.modifiers:
            if modifier['name'] == 'frame':
                frame = self.layout_converter.parse_frame(modifier.get('value', ''))
                properties.update(frame)
            elif modifier['name'] == 'foregroundColor':
                color = self.color_converter.convert(modifier.get('value', ''))
                properties['fills'] = [{'type': 'SOLID', 'color': color}]

        return FigmaNode(
            type='RECTANGLE',
            name=component.type,
            properties=properties
        )

    def _map_stack(self, component: UIComponent) -> FigmaNode:
        """Map Stack to Figma FRAME with auto-layout"""
        properties = {
            'width': 200,
            'height': 200,
            'layoutMode': 'VERTICAL' if component.type == 'VStack' else 'HORIZONTAL',
        }

        # Parse spacing from params
        params = component.properties.get('params', '')
        spacing_match = re.search(r'spacing:\s*([\d.]+)', params)
        if spacing_match:
            properties['itemSpacing'] = float(spacing_match.group(1))

        return FigmaNode(
            type='FRAME',
            name=component.type,
            properties=properties,
            children=[]
        )

    def _map_uikit_component(self, component: UIComponent) -> Optional[FigmaNode]:
        """Map UIKit component to Figma node"""

        if component.type == 'UILabel':
            return FigmaNode(
                type='TEXT',
                name='UILabel',
                properties={
                    'characters': component.properties.get('text', 'Label'),
                    'fontSize': 17,
                    'fills': [{'type': 'SOLID', 'color': {'r': 0, 'g': 0, 'b': 0}}]
                }
            )
        elif component.type == 'UIButton':
            return FigmaNode(
                type='FRAME',
                name='UIButton',
                properties={
                    'width': 120,
                    'height': 44,
                    'fills': [{'type': 'SOLID', 'color': {'r': 0.0, 'g': 0.478, 'b': 1.0}}],
                    'cornerRadius': 8
                }
            )
        elif component.type == 'UIImageView':
            return FigmaNode(
                type='RECTANGLE',
                name='UIImageView',
                properties={
                    'width': 100,
                    'height': 100,
                    'fills': [{'type': 'SOLID', 'color': {'r': 0.9, 'g': 0.9, 'b': 0.9}}]
                }
            )
        elif component.type == 'UIView':
            return FigmaNode(
                type='FRAME',
                name='UIView',
                properties={
                    'width': 200,
                    'height': 200,
                    'fills': [{'type': 'SOLID', 'color': {'r': 1.0, 'g': 1.0, 'b': 1.0}}]
                }
            )

        return None
