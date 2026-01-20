#!/usr/bin/env python3
"""
iOS to Figma Converter

A command-line tool to convert iOS native code (SwiftUI/UIKit) to Figma designs.

Usage:
    python ios_to_figma.py <input_file.swift> [options]

Examples:
    # Convert SwiftUI file and generate plugin code
    python ios_to_figma.py HomeView.swift --output plugin.ts

    # Convert UIKit file and export JSON
    python ios_to_figma.py ViewController.swift --json design.json

    # Process entire directory
    python ios_to_figma.py ios_app/ --recursive
"""

import sys
import os
import argparse
from typing import List, Optional

# Add current directory to path for imports
sys.path.insert(0, os.path.dirname(__file__))

from ios_parser import iOSCodeParser, UIComponent
from component_mapper import ComponentMapper
from figma_api import FigmaNode, FigmaPluginGenerator, FigmaDesignExporter


class iOSToFigmaConverter:
    """Main converter orchestrating the conversion process"""

    def __init__(self):
        self.parser = iOSCodeParser()
        self.mapper = ComponentMapper()
        self.plugin_generator = FigmaPluginGenerator()
        self.exporter = FigmaDesignExporter()

    def convert_file(self, file_path: str, options: dict) -> bool:
        """
        Convert a single iOS file to Figma

        Args:
            file_path: Path to Swift file
            options: Conversion options (output format, etc.)

        Returns:
            True if successful, False otherwise
        """
        print(f"🔍 Parsing iOS code from: {file_path}")

        try:
            # Parse iOS code
            ios_components = self.parser.parse_file(file_path)

            if not ios_components:
                print(f"⚠️  No UI components found in {file_path}")
                return False

            print(f"✅ Found {len(ios_components)} UI components")

            # Map to Figma nodes
            print("🔄 Mapping iOS components to Figma design...")
            figma_nodes = self.mapper.map_components(ios_components)

            print(f"✅ Mapped {len(figma_nodes)} Figma nodes")

            # Generate output
            base_name = os.path.splitext(os.path.basename(file_path))[0]
            self._generate_output(figma_nodes, base_name, options)

            return True

        except Exception as e:
            print(f"❌ Error converting {file_path}: {e}")
            import traceback
            traceback.print_exc()
            return False

    def convert_directory(self, directory: str, options: dict) -> bool:
        """Convert all Swift files in a directory"""
        print(f"📂 Processing directory: {directory}")

        results = self.parser.parse_directory(directory)

        if not results:
            print("⚠️  No Swift files with UI components found")
            return False

        print(f"✅ Found {len(results)} files with UI components")

        success_count = 0
        for file_path, ios_components in results.items():
            print(f"\n📄 Processing: {file_path}")
            figma_nodes = self.mapper.map_components(ios_components)

            if figma_nodes:
                base_name = os.path.splitext(os.path.basename(file_path))[0]
                self._generate_output(figma_nodes, base_name, options)
                success_count += 1

        print(f"\n✅ Successfully converted {success_count}/{len(results)} files")
        return success_count > 0

    def _generate_output(self, figma_nodes: List[FigmaNode], base_name: str, options: dict):
        """Generate output files based on options"""

        output_dir = options.get('output_dir', 'figma_output')
        os.makedirs(output_dir, exist_ok=True)

        # Generate Figma Plugin code (default)
        if options.get('plugin', True):
            plugin_path = os.path.join(output_dir, f"{base_name}_plugin.ts")
            plugin_code = self.plugin_generator.generate_plugin_code(
                figma_nodes,
                frame_name=base_name
            )
            self.plugin_generator.save_plugin_code(plugin_code, plugin_path)

        # Generate JSON export
        if options.get('json', False):
            json_path = os.path.join(output_dir, f"{base_name}_design.json")
            self.exporter.export_to_json(figma_nodes, json_path)

        # Generate HTML preview
        if options.get('preview', False):
            preview_path = os.path.join(output_dir, f"{base_name}_preview.html")
            self._generate_preview(figma_nodes, base_name, preview_path)

    def _generate_preview(self, figma_nodes: List[FigmaNode], title: str, output_path: str):
        """Generate HTML preview of the design"""

        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} - Design Preview</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            padding: 40px;
            background: #f5f5f5;
        }}
        .container {{
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }}
        h1 {{
            color: #333;
            margin-bottom: 30px;
        }}
        .component {{
            padding: 15px;
            margin: 10px 0;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            background: #fafafa;
        }}
        .component-type {{
            font-weight: 600;
            color: #0066cc;
            margin-bottom: 8px;
        }}
        .component-props {{
            font-size: 14px;
            color: #666;
            font-family: 'Courier New', monospace;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>{title} - Design Components</h1>
"""

        for i, node in enumerate(figma_nodes):
            html += f"""
        <div class="component">
            <div class="component-type">{i + 1}. {node.type} - {node.name}</div>
            <div class="component-props">
                <pre>{self._format_properties(node.properties)}</pre>
            </div>
        </div>
"""

        html += """
    </div>
</body>
</html>
"""

        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html)

        print(f"✅ Preview saved to: {output_path}")

    def _format_properties(self, props: dict) -> str:
        """Format properties for display"""
        import json
        return json.dumps(props, indent=2)


def main():
    """Main entry point for CLI"""

    parser = argparse.ArgumentParser(
        description='Convert iOS native code to Figma designs',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Convert single file
  python ios_to_figma.py HomeView.swift

  # Convert with custom output directory
  python ios_to_figma.py HomeView.swift --output-dir my_designs

  # Convert and export JSON
  python ios_to_figma.py HomeView.swift --json

  # Convert entire directory
  python ios_to_figma.py ios_app/ --recursive

  # Generate preview HTML
  python ios_to_figma.py HomeView.swift --preview

For more information, see README_IOS_TO_FIGMA.md
        """
    )

    parser.add_argument(
        'input',
        help='Input Swift file or directory'
    )

    parser.add_argument(
        '-o', '--output-dir',
        default='figma_output',
        help='Output directory for generated files (default: figma_output)'
    )

    parser.add_argument(
        '-r', '--recursive',
        action='store_true',
        help='Process directory recursively'
    )

    parser.add_argument(
        '--json',
        action='store_true',
        help='Export design as JSON'
    )

    parser.add_argument(
        '--preview',
        action='store_true',
        help='Generate HTML preview'
    )

    parser.add_argument(
        '--no-plugin',
        action='store_true',
        help='Skip Figma plugin code generation'
    )

    args = parser.parse_args()

    # Validate input
    if not os.path.exists(args.input):
        print(f"❌ Error: '{args.input}' not found")
        sys.exit(1)

    # Prepare options
    options = {
        'output_dir': args.output_dir,
        'plugin': not args.no_plugin,
        'json': args.json,
        'preview': args.preview,
    }

    # Create converter
    converter = iOSToFigmaConverter()

    # Convert
    print("=" * 60)
    print("iOS to Figma Converter")
    print("=" * 60)

    if os.path.isdir(args.input):
        if not args.recursive:
            print("⚠️  Input is a directory. Use --recursive to process all files.")
            sys.exit(1)
        success = converter.convert_directory(args.input, options)
    else:
        success = converter.convert_file(args.input, options)

    print("=" * 60)

    if success:
        print("✅ Conversion complete!")
        print(f"\n📁 Output directory: {args.output_dir}")
        print("\nNext steps:")
        print("1. Open Figma Desktop App")
        print("2. Go to Plugins → Development → New Plugin")
        print("3. Choose 'Figma design' template")
        print("4. Copy the generated plugin code (*.ts file)")
        print("5. Run the plugin to create your design!")
        sys.exit(0)
    else:
        print("❌ Conversion failed")
        sys.exit(1)


if __name__ == '__main__':
    main()
