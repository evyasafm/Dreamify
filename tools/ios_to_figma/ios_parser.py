"""
iOS Code Parser for SwiftUI and UIKit

This module parses iOS native code (Swift, SwiftUI, UIKit) and extracts
UI components, layouts, and styling information.
"""

import re
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, field


@dataclass
class UIComponent:
    """Represents a UI component extracted from iOS code"""
    type: str  # Text, Button, Image, VStack, HStack, etc.
    properties: Dict[str, Any] = field(default_factory=dict)
    children: List['UIComponent'] = field(default_factory=list)
    frame: Optional[Dict[str, float]] = None
    modifiers: List[Dict[str, Any]] = field(default_factory=list)


class SwiftUIParser:
    """Parser for SwiftUI code"""

    # SwiftUI component patterns
    COMPONENT_PATTERNS = {
        'Text': r'Text\("([^"]*)"\)',
        'Button': r'Button\((.*?)\)\s*\{',
        'Image': r'Image\((?:systemName:\s*"([^"]*)"|(.*?))\)',
        'VStack': r'VStack\((.*?)\)\s*\{',
        'HStack': r'HStack\((.*?)\)\s*\{',
        'ZStack': r'ZStack\((.*?)\)\s*\{',
        'Rectangle': r'Rectangle\(\)',
        'Circle': r'Circle\(\)',
        'RoundedRectangle': r'RoundedRectangle\(cornerRadius:\s*([\d.]+)\)',
        'Spacer': r'Spacer\(\)',
        'Divider': r'Divider\(\)',
    }

    # Modifier patterns
    MODIFIER_PATTERNS = {
        'font': r'\.font\((.*?)\)',
        'foregroundColor': r'\.foregroundColor\((.*?)\)',
        'background': r'\.background\((.*?)\)',
        'frame': r'\.frame\((.*?)\)',
        'padding': r'\.padding\((.*?)\)',
        'cornerRadius': r'\.cornerRadius\((.*?)\)',
        'opacity': r'\.opacity\((.*?)\)',
        'offset': r'\.offset\((.*?)\)',
        'shadow': r'\.shadow\((.*?)\)',
        'bold': r'\.bold\(\)',
        'italic': r'\.italic\(\)',
    }

    def parse(self, code: str) -> List[UIComponent]:
        """Parse SwiftUI code and extract UI components"""
        components = []

        # Remove comments
        code = self._remove_comments(code)

        # Find all components
        for component_type, pattern in self.COMPONENT_PATTERNS.items():
            matches = re.finditer(pattern, code, re.MULTILINE | re.DOTALL)
            for match in matches:
                component = self._parse_component(component_type, match, code)
                if component:
                    components.append(component)

        return components

    def _remove_comments(self, code: str) -> str:
        """Remove single-line and multi-line comments"""
        # Remove single-line comments
        code = re.sub(r'//.*?$', '', code, flags=re.MULTILINE)
        # Remove multi-line comments
        code = re.sub(r'/\*.*?\*/', '', code, flags=re.DOTALL)
        return code

    def _parse_component(self, component_type: str, match: re.Match, full_code: str) -> Optional[UIComponent]:
        """Parse a single component and its properties"""
        component = UIComponent(type=component_type)

        # Extract component content
        if component_type == 'Text':
            component.properties['text'] = match.group(1)
        elif component_type == 'Image':
            if match.group(1):
                component.properties['systemName'] = match.group(1)
            else:
                component.properties['name'] = match.group(2)
        elif component_type == 'Button':
            component.properties['action'] = match.group(1)
        elif component_type in ['VStack', 'HStack', 'ZStack']:
            # Parse alignment and spacing
            params = match.group(1)
            if params:
                component.properties['params'] = params
        elif component_type == 'RoundedRectangle':
            component.properties['cornerRadius'] = float(match.group(1))

        # Parse modifiers for this component
        start_pos = match.start()
        end_pos = self._find_component_end(full_code, start_pos)
        component_code = full_code[start_pos:end_pos]
        component.modifiers = self._parse_modifiers(component_code)

        return component

    def _find_component_end(self, code: str, start: int) -> int:
        """Find the end of a component declaration"""
        # Simple heuristic: find the next newline without a modifier
        pos = start
        while pos < len(code):
            char = code[pos]
            if char == '\n':
                # Check if next line starts with a modifier
                next_line_start = pos + 1
                while next_line_start < len(code) and code[next_line_start].isspace():
                    next_line_start += 1
                if next_line_start >= len(code) or code[next_line_start] != '.':
                    return pos
            pos += 1
        return len(code)

    def _parse_modifiers(self, code: str) -> List[Dict[str, Any]]:
        """Parse modifiers applied to a component"""
        modifiers = []

        for modifier_name, pattern in self.MODIFIER_PATTERNS.items():
            matches = re.finditer(pattern, code)
            for match in matches:
                modifier_data = {'name': modifier_name}
                if match.groups():
                    modifier_data['value'] = match.group(1)
                else:
                    modifier_data['value'] = True
                modifiers.append(modifier_data)

        return modifiers


class UIKitParser:
    """Parser for UIKit code"""

    # UIKit component patterns
    COMPONENT_PATTERNS = {
        'UILabel': r'(?:let|var)\s+(\w+)\s*=\s*UILabel\(\)',
        'UIButton': r'(?:let|var)\s+(\w+)\s*=\s*UIButton\((.*?)\)',
        'UIImageView': r'(?:let|var)\s+(\w+)\s*=\s*UIImageView\((.*?)\)',
        'UIView': r'(?:let|var)\s+(\w+)\s*=\s*UIView\((.*?)\)',
        'UIStackView': r'(?:let|var)\s+(\w+)\s*=\s*UIStackView\((.*?)\)',
        'UITextField': r'(?:let|var)\s+(\w+)\s*=\s*UITextField\((.*?)\)',
        'UITextView': r'(?:let|var)\s+(\w+)\s*=\s*UITextView\((.*?)\)',
    }

    # Property patterns
    PROPERTY_PATTERNS = {
        'text': r'\.text\s*=\s*"([^"]*)"',
        'textColor': r'\.textColor\s*=\s*(.*?)(?:\n|;)',
        'backgroundColor': r'\.backgroundColor\s*=\s*(.*?)(?:\n|;)',
        'font': r'\.font\s*=\s*(.*?)(?:\n|;)',
        'frame': r'\.frame\s*=\s*CGRect\((.*?)\)',
        'cornerRadius': r'\.layer\.cornerRadius\s*=\s*([\d.]+)',
        'alpha': r'\.alpha\s*=\s*([\d.]+)',
    }

    def parse(self, code: str) -> List[UIComponent]:
        """Parse UIKit code and extract UI components"""
        components = []

        # Remove comments
        code = self._remove_comments(code)

        # Find all component declarations
        for component_type, pattern in self.COMPONENT_PATTERNS.items():
            matches = re.finditer(pattern, code, re.MULTILINE | re.DOTALL)
            for match in matches:
                component = self._parse_component(component_type, match, code)
                if component:
                    components.append(component)

        return components

    def _remove_comments(self, code: str) -> str:
        """Remove single-line and multi-line comments"""
        code = re.sub(r'//.*?$', '', code, flags=re.MULTILINE)
        code = re.sub(r'/\*.*?\*/', '', code, flags=re.DOTALL)
        return code

    def _parse_component(self, component_type: str, match: re.Match, full_code: str) -> Optional[UIComponent]:
        """Parse a single UIKit component"""
        component = UIComponent(type=component_type)
        variable_name = match.group(1)
        component.properties['variableName'] = variable_name

        # Find properties for this variable
        # Look for lines like: variableName.property = value
        var_pattern = re.escape(variable_name) + r'\.'
        properties_section = self._extract_properties_section(full_code, match.end(), variable_name)

        for prop_name, prop_pattern in self.PROPERTY_PATTERNS.items():
            prop_matches = re.finditer(var_pattern + prop_pattern, properties_section)
            for prop_match in prop_matches:
                component.properties[prop_name] = prop_match.group(1)

        return component

    def _extract_properties_section(self, code: str, start_pos: int, var_name: str) -> str:
        """Extract the section of code with properties for a variable"""
        # Extract next ~50 lines or until next component declaration
        lines = code[start_pos:].split('\n')[:50]
        return '\n'.join(lines)


class iOSCodeParser:
    """Main parser that handles both SwiftUI and UIKit code"""

    def __init__(self):
        self.swiftui_parser = SwiftUIParser()
        self.uikit_parser = UIKitParser()

    def parse_file(self, file_path: str) -> List[UIComponent]:
        """Parse an iOS source file"""
        with open(file_path, 'r', encoding='utf-8') as f:
            code = f.read()
        return self.parse_code(code)

    def parse_code(self, code: str) -> List[UIComponent]:
        """Parse iOS code and detect whether it's SwiftUI or UIKit"""
        components = []

        # Detect code type
        is_swiftui = 'import SwiftUI' in code or 'View' in code and '{' in code
        is_uikit = 'import UIKit' in code or 'UIView' in code

        if is_swiftui:
            components.extend(self.swiftui_parser.parse(code))

        if is_uikit:
            components.extend(self.uikit_parser.parse(code))

        return components

    def parse_directory(self, directory: str) -> Dict[str, List[UIComponent]]:
        """Parse all Swift files in a directory"""
        import os
        import glob

        results = {}
        swift_files = glob.glob(os.path.join(directory, '**/*.swift'), recursive=True)

        for file_path in swift_files:
            try:
                components = self.parse_file(file_path)
                if components:
                    results[file_path] = components
            except Exception as e:
                print(f"Error parsing {file_path}: {e}")

        return results
