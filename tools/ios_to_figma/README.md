# iOS to Figma Converter

Convert iOS native code (Swift, SwiftUI, UIKit) to Figma designs programmatically.

## Features

- **SwiftUI Support**: Parse and convert SwiftUI views
- **UIKit Support**: Parse and convert UIKit components
- **Figma Plugin Generation**: Creates TypeScript code that runs inside Figma
- **JSON Export**: Export design specifications as JSON
- **HTML Preview**: Generate visual preview of components
- **Batch Processing**: Convert entire directories of Swift files

## Supported Components

### SwiftUI
- ✅ Text
- ✅ Button
- ✅ Image
- ✅ VStack, HStack, ZStack
- ✅ Rectangle, Circle, RoundedRectangle
- ✅ Spacer, Divider
- ✅ Common modifiers (font, foregroundColor, background, frame, padding, cornerRadius, etc.)

### UIKit
- ✅ UILabel
- ✅ UIButton
- ✅ UIImageView
- ✅ UIView
- ✅ UIStackView
- ✅ UITextField
- ✅ UITextView

## Installation

1. **Clone or navigate to the tool directory:**
   ```bash
   cd tools/ios_to_figma
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Make the script executable (optional):**
   ```bash
   chmod +x ios_to_figma.py
   ```

## Usage

### Basic Usage

Convert a single SwiftUI file:
```bash
python ios_to_figma.py examples/ProfileView.swift
```

This will:
1. Parse the Swift code
2. Extract UI components
3. Map them to Figma elements
4. Generate Figma plugin code in `figma_output/`

### Advanced Usage

**Custom output directory:**
```bash
python ios_to_figma.py ProfileView.swift --output-dir my_designs
```

**Export as JSON:**
```bash
python ios_to_figma.py ProfileView.swift --json
```

**Generate HTML preview:**
```bash
python ios_to_figma.py ProfileView.swift --preview
```

**Convert entire directory:**
```bash
python ios_to_figma.py ios_app/ --recursive
```

**All options combined:**
```bash
python ios_to_figma.py ProfileView.swift \
  --output-dir my_designs \
  --json \
  --preview
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `input` | Input Swift file or directory (required) |
| `-o, --output-dir DIR` | Output directory (default: `figma_output`) |
| `-r, --recursive` | Process directory recursively |
| `--json` | Export design as JSON |
| `--preview` | Generate HTML preview |
| `--no-plugin` | Skip Figma plugin code generation |

## How to Use Generated Figma Plugin Code

Since the Figma REST API is read-only, we generate Figma Plugin code that you can run inside Figma to create designs.

### Steps:

1. **Run the converter:**
   ```bash
   python ios_to_figma.py examples/ProfileView.swift
   ```

2. **Open Figma Desktop App**

3. **Create a new plugin:**
   - Go to **Plugins → Development → New Plugin**
   - Choose **"Figma design"** template
   - Name it (e.g., "iOS Design Importer")

4. **Copy the generated code:**
   - Open `figma_output/ProfileView_plugin.ts`
   - Copy all the code

5. **Paste into plugin:**
   - Replace the content of `code.ts` in your Figma plugin
   - Save the file

6. **Run the plugin:**
   - In Figma: **Plugins → Development → [Your Plugin Name]**
   - The design will be created automatically!

## Examples

### Example 1: Profile View

```swift
// ProfileView.swift
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .foregroundColor(.gray)
                .frame(width: 120, height: 120)

            Text("John Doe")
                .font(.title)
                .bold()

            Text("iOS Developer")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
```

**Convert:**
```bash
python ios_to_figma.py examples/ProfileView.swift
```

**Output:**
- `figma_output/ProfileView_plugin.ts` - Figma plugin code
- Creates a Figma frame with:
  - Circle (120x120, gray)
  - Text "John Doe" (title, bold)
  - Text "iOS Developer" (subheadline, gray)

### Example 2: Login Screen

```bash
python ios_to_figma.py examples/LoginView.swift --preview
```

Opens an HTML preview showing all extracted components.

### Example 3: Batch Conversion

```bash
python ios_to_figma.py ios_app/ --recursive --json
```

Converts all Swift files in the directory and exports JSON specifications.

## Architecture

The converter consists of four main modules:

### 1. `ios_parser.py`
Parses iOS code and extracts UI components.

**Classes:**
- `SwiftUIParser` - Parses SwiftUI syntax
- `UIKitParser` - Parses UIKit declarations
- `iOSCodeParser` - Main parser that detects and delegates

### 2. `component_mapper.py`
Maps iOS components to Figma design elements.

**Classes:**
- `ComponentMapper` - Main mapping logic
- `ColorConverter` - iOS colors → Figma RGB
- `FontConverter` - iOS fonts → Figma typography
- `LayoutConverter` - iOS frames → Figma dimensions

### 3. `figma_api.py`
Handles Figma integration and plugin generation.

**Classes:**
- `FigmaAPI` - REST API client (read-only)
- `FigmaPluginGenerator` - Generates TypeScript plugin code
- `FigmaDesignExporter` - Exports to JSON/other formats
- `FigmaNode` - Represents a Figma design node

### 4. `ios_to_figma.py`
Main CLI tool that orchestrates the conversion.

**Class:**
- `iOSToFigmaConverter` - Coordinates parsing, mapping, and output generation

## Component Mapping

### Text → Figma TEXT

| iOS Property | Figma Property |
|--------------|----------------|
| `.font(.title)` | `fontSize: 28` |
| `.foregroundColor(.blue)` | `fills: [{color: {r:0, g:0.478, b:1}}]` |
| `.bold()` | `fontWeight: 700` |

### Button → Figma FRAME

Buttons are converted to frames with:
- Background fill (from `.background()` modifier)
- Corner radius (from `.cornerRadius()` modifier)
- Fixed dimensions (from `.frame()` modifier)

### Shapes → Figma RECTANGLE

| iOS Shape | Figma Mapping |
|-----------|---------------|
| `Rectangle()` | RECTANGLE with `cornerRadius: 0` |
| `Circle()` | RECTANGLE with `cornerRadius: 50` |
| `RoundedRectangle(cornerRadius: 10)` | RECTANGLE with `cornerRadius: 10` |

### Stacks → Figma FRAME with Auto-Layout

| iOS Stack | Figma Layout |
|-----------|--------------|
| `VStack` | FRAME with `layoutMode: VERTICAL` |
| `HStack` | FRAME with `layoutMode: HORIZONTAL` |
| `ZStack` | FRAME (absolute positioning) |

## Limitations

1. **Figma REST API is Read-Only**: Direct design creation isn't possible via REST API. We generate plugin code instead.

2. **Dynamic Content**: Variables and state are converted to their default/placeholder values.

3. **Complex Layouts**: Auto Layout constraints may need manual adjustment in Figma.

4. **Custom Fonts**: Only system fonts are supported. Custom fonts need to be loaded in Figma.

5. **Images**: Actual image assets aren't transferred; placeholders are created.

6. **Animations**: SwiftUI animations aren't supported in static Figma designs.

## Roadmap

- [ ] Support for more SwiftUI components (ScrollView, List, NavigationView)
- [ ] Better Auto Layout constraint mapping
- [ ] Component variants support
- [ ] Direct Figma API integration (when available)
- [ ] Storyboard/XIB file support
- [ ] Design tokens extraction
- [ ] Figma Variables integration
- [ ] Live preview mode

## Troubleshooting

### No components found

**Problem:** "No UI components found in file"

**Solution:**
- Ensure the file contains SwiftUI views or UIKit components
- Check that `import SwiftUI` or `import UIKit` is present
- Verify the code compiles in Xcode

### Plugin doesn't work in Figma

**Problem:** Plugin code fails to run

**Solution:**
- Make sure you're using Figma Desktop (plugins don't work in browser for development)
- Check the console for errors (Plugins → Development → Open Console)
- Ensure you copied the entire plugin code

### Colors look wrong

**Problem:** Colors don't match iOS appearance

**Solution:**
- iOS uses different color spaces (Display P3 vs sRGB)
- Manually adjust colors in Figma if needed
- Check if dark mode colors were used

## Contributing

Contributions are welcome! Areas for improvement:

1. **Parser enhancements** - Support more SwiftUI components
2. **Layout mapping** - Better Auto Layout conversion
3. **UIKit support** - Expand UIKit component coverage
4. **Testing** - Add unit tests for parsers and mappers
5. **Documentation** - More examples and tutorials

## License

MIT License - see main project LICENSE file.

## Support

For issues, questions, or feature requests, please open an issue on the main Dreamify repository.

## Acknowledgments

- Built for the Dreamify project
- Inspired by tools like Anima, Bravo Studio, and Supernova
- Uses the Figma Plugin API

---

**Made with ❤️ for iOS developers and designers**
