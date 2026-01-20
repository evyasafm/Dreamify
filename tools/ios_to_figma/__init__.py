"""iOS to Figma Converter Package"""

__version__ = '1.0.0'
__author__ = 'Dreamify'
__description__ = 'Convert iOS native code (SwiftUI/UIKit) to Figma designs'

from .ios_parser import iOSCodeParser, UIComponent
from .component_mapper import ComponentMapper
from .figma_api import FigmaNode, FigmaPluginGenerator, FigmaAPI

__all__ = [
    'iOSCodeParser',
    'UIComponent',
    'ComponentMapper',
    'FigmaNode',
    'FigmaPluginGenerator',
    'FigmaAPI',
]
